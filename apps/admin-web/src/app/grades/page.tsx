'use client';

import { useEffect, useMemo, useState } from 'react';

import { AdminShell } from '@/components/AdminShell';
import { RequireAuth } from '@/components/RequireAuth';
import {
	apiFetch,
	fetchAssessmentGrades,
	fetchCohortStudents,
	type AssessmentGrade,
	type CohortStudent,
} from '@/lib/api';

type Course = {
	id: string;
	name: string;
	subject: string;
	cohortId: string | null;
};

type Assessment = {
	id: string;
	courseId: string;
	title: string;
	date: string;
	maxGrade?: number | null;
	createdBy?: string | null;
	course?: Course;
};

type ListAssessmentsResp =
	| { ok: true; courses: Course[]; assessments: Assessment[] }
	| { ok: true; course: Course; assessments: Assessment[] };

type GradeDraft = Record<string, number | ''>;

function assessmentDateLabel(value: string) {
	const date = new Date(value);
	if (Number.isNaN(date.getTime())) return value;
	return date.toISOString().slice(0, 10);
}

export default function GradesPage() {
	const [loading, setLoading] = useState(false);
	const [saving, setSaving] = useState(false);
	const [err, setErr] = useState<string | null>(null);
	const [saveMessage, setSaveMessage] = useState<string | null>(null);

	const [courses, setCourses] = useState<Course[]>([]);
	const [assessments, setAssessments] = useState<Assessment[]>([]);
	const [selectedId, setSelectedId] = useState<string | null>(null);
	const [students, setStudents] = useState<CohortStudent[]>([]);
	const [gradesDraft, setGradesDraft] = useState<GradeDraft>({});
	const [initialGrades, setInitialGrades] = useState<GradeDraft>({});
	const [gradeErrors, setGradeErrors] = useState<Record<string, string>>({});

	const [courseId, setCourseId] = useState('');
	const [title, setTitle] = useState('');
	const [date, setDate] = useState('');
	const [maxGrade, setMaxGrade] = useState('');

	const selectedAssessment = useMemo(
		() => assessments.find((assessment) => assessment.id === selectedId) ?? null,
		[assessments, selectedId],
	);

	const dirtyStudentIds = useMemo(
		() => students
			.map((student) => student.studentId)
			.filter((studentId) => gradesDraft[studentId] !== initialGrades[studentId]),
		[gradesDraft, initialGrades, students],
	);

	async function refresh() {
		setErr(null);
		setSaveMessage(null);
		setLoading(true);
		try {
			const response = await apiFetch<ListAssessmentsResp>('/teacher/grades/assessments');
			const nextCourses = 'courses' in response ? response.courses : [response.course];
			setCourses(nextCourses);
			setAssessments(response.assessments ?? []);
			if (!courseId && nextCourses.length > 0) {
				setCourseId(nextCourses[0].id);
			}
		} catch (error) {
			setErr(error instanceof Error ? error.message : 'Failed to load grades workspace');
		} finally {
			setLoading(false);
		}
	}

	async function createAssessment() {
		if (!courseId || !title.trim()) return;

		setErr(null);
		setSaveMessage(null);
		setLoading(true);
		try {
			const body: { courseId: string; title: string; date?: string; maxGrade?: number } = {
				courseId,
				title: title.trim(),
			};
			if (date.trim()) body.date = date.trim();
			if (maxGrade.trim()) {
				const parsed = Number(maxGrade);
				if (!Number.isFinite(parsed) || parsed <= 0) {
					throw new Error('Max grade must be a positive number');
				}
				body.maxGrade = Math.round(parsed);
			}

			await apiFetch('/teacher/grades/assessment', {
				method: 'POST',
				body: JSON.stringify(body),
			});

			setTitle('');
			setDate('');
			setMaxGrade('');
			await refresh();
			setSaveMessage('Assessment created.');
		} catch (error) {
			setErr(error instanceof Error ? error.message : 'Failed to create assessment');
		} finally {
			setLoading(false);
		}
	}

	async function openAssessment(assessment: Assessment) {
		setSelectedId(assessment.id);
		setErr(null);
		setSaveMessage(null);
		setStudents([]);
		setGradesDraft({});
		setInitialGrades({});
		setGradeErrors({});

		const linkedCourse = assessment.course ?? courses.find((course) => course.id === assessment.courseId);
		const linkedCohortId = linkedCourse?.cohortId ?? '';
		if (!linkedCohortId) {
			setErr('This assessment is not linked to a cohort roster yet.');
			return;
		}

		try {
			const [rosterRes, gradesRes] = await Promise.all([
				fetchCohortStudents(linkedCohortId),
				fetchAssessmentGrades(assessment.id),
			]);

			const roster = rosterRes.students ?? [];
			const gradeMap = new Map<string, number | ''>(
				(gradesRes.grades ?? []).map((grade: AssessmentGrade) => [grade.studentId, grade.grade ?? '']),
			);
			const nextDraft: GradeDraft = {};
			for (const student of roster) {
				nextDraft[student.studentId] = gradeMap.get(student.studentId) ?? '';
			}

			setStudents(roster);
			setGradesDraft(nextDraft);
			setInitialGrades(nextDraft);
		} catch (error) {
			setErr(error instanceof Error ? error.message : 'Failed to load cohort students');
		}
	}

	async function saveGrades() {
		if (!selectedAssessment || dirtyStudentIds.length === 0) return;

		setSaving(true);
		setErr(null);
		setSaveMessage(null);
		try {
			await apiFetch('/teacher/grades/bulk', {
				method: 'POST',
				body: JSON.stringify({
					assessmentId: selectedAssessment.id,
					grades: dirtyStudentIds
						.filter((studentId) => gradesDraft[studentId] !== '')
						.map((studentId) => ({ studentId, grade: Number(gradesDraft[studentId]) })),
				}),
			});
			setInitialGrades({ ...gradesDraft });
			setSaveMessage('Grades saved.');
		} catch (error) {
			setErr(error instanceof Error ? error.message : 'Save grades failed');
		} finally {
			setSaving(false);
		}
	}

	async function deleteAssessment(id: string) {
		if (!window.confirm('Delete this assessment? Grades will be deleted too.')) return;

		setErr(null);
		try {
			await apiFetch(`/teacher/grades/assessment/${id}`, { method: 'DELETE' });
			setAssessments((current) => current.filter((assessment) => assessment.id !== id));
			if (selectedId === id) {
				setSelectedId(null);
				setStudents([]);
				setGradesDraft({});
				setInitialGrades({});
			}
		} catch (error) {
			setErr(error instanceof Error ? error.message : 'Delete failed');
		}
	}

	useEffect(() => {
		void refresh();
	}, []);

	const byCourse = useMemo(() => {
		const map = new Map<string, Assessment[]>();
		for (const assessment of assessments) {
			if (!map.has(assessment.courseId)) map.set(assessment.courseId, []);
			map.get(assessment.courseId)!.push(assessment);
		}
		return map;
	}, [assessments]);

	return (
		<RequireAuth>
			<AdminShell>
				<div className="teacher-page">
					<div className="flex items-start justify-between gap-4">
						<div>
							<div className="teacher-kicker">Assessments & Grades</div>
							<h1 className="mt-2 text-3xl font-semibold">Assess, open rosters, and publish grades</h1>
							<p className="teacher-muted mt-2 text-sm">
								Create assessments, open class rosters, and save grades into the live teacher system.
							</p>
						</div>
						<button
							className="teacher-button-secondary rounded-xl px-3 py-2 text-sm transition hover:bg-white/90 disabled:opacity-50"
							disabled={loading}
							onClick={refresh}
						>
							{loading ? 'Refreshing…' : 'Refresh'}
						</button>
					</div>

					{err ? (
						<div className="rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">
							{err}
						</div>
					) : null}

					{saveMessage ? (
						<div className="rounded border border-green-200 bg-green-50 p-3 text-sm text-green-700">
							{saveMessage}
						</div>
					) : null}

					<section className="teacher-panel rounded-[1.75rem] p-5">
						<h2 className="text-sm font-semibold">Create assessment</h2>
						<div className="mt-3 grid gap-3 md:grid-cols-4">
							<div>
								<label className="text-xs text-gray-600">Course</label>
								<select
									className="mt-1 w-full rounded border px-3 py-2 text-sm"
									value={courseId}
									onChange={(event) => setCourseId(event.target.value)}
								>
									{courses.map((course) => (
										<option key={course.id} value={course.id}>
											{course.name}
										</option>
									))}
								</select>
							</div>
							<div>
								<label className="text-xs text-gray-600">Title</label>
								<input
									className="mt-1 w-full rounded border px-3 py-2 text-sm"
									value={title}
									onChange={(event) => setTitle(event.target.value)}
									placeholder="e.g. Quiz 3"
								/>
							</div>
							<div>
								<label className="text-xs text-gray-600">Date</label>
								<input
									className="mt-1 w-full rounded border px-3 py-2 text-sm"
									value={date}
									onChange={(event) => setDate(event.target.value)}
									placeholder="YYYY-MM-DD"
								/>
							</div>
							<div>
								<label className="text-xs text-gray-600">Max grade</label>
								<input
									className="mt-1 w-full rounded border px-3 py-2 text-sm"
									value={maxGrade}
									onChange={(event) => setMaxGrade(event.target.value)}
									placeholder="e.g. 100"
								/>
							</div>
						</div>
						<div className="mt-3">
							<button
								className="teacher-button-primary rounded-xl px-3 py-2 text-sm transition hover:opacity-95 disabled:opacity-50"
								disabled={loading || !courseId || !title.trim()}
								onClick={createAssessment}
							>
								Create
							</button>
						</div>
					</section>

					{selectedAssessment ? (
						<section className="teacher-panel rounded-[1.75rem] p-5" data-testid="grade-entry">
							<div className="flex items-center justify-between gap-4">
								<div>
									<h2 className="text-lg font-semibold">{selectedAssessment.title}</h2>
									<p className="teacher-muted mt-1 text-sm">
										{(selectedAssessment.course?.name ?? courses.find((course) => course.id === selectedAssessment.courseId)?.name ?? 'Course')} · Due {assessmentDateLabel(selectedAssessment.date)} · Max {selectedAssessment.maxGrade ?? '—'}
									</p>
								</div>
								<button
									className="teacher-button-primary rounded-xl px-3 py-2 text-sm transition hover:opacity-95 disabled:opacity-50"
									aria-label="Save grades"
									disabled={saving || dirtyStudentIds.length === 0 || Object.keys(gradeErrors).length > 0}
									onClick={saveGrades}
								>
									{saving ? 'Saving…' : `Save ${dirtyStudentIds.length || ''} grade${dirtyStudentIds.length === 1 ? '' : 's'}`}
								</button>
							</div>

							{students.length === 0 ? (
								<div className="mt-4 text-sm text-gray-500">No students loaded.</div>
							) : (
								<div className="mt-4 overflow-hidden rounded-2xl border border-slate-200/80">
									<table className="teacher-grid-table w-full text-sm" data-testid="grades-entry-table">
										<thead className="text-left text-gray-600">
											<tr>
												<th className="px-3 py-2">Student</th>
												<th className="px-3 py-2">Email</th>
												<th className="px-3 py-2">Grade</th>
											</tr>
										</thead>
										<tbody>
											{students.map((student) => {
												const studentId = student.studentId;
												return (
													<tr key={studentId} className="border-t border-slate-200/70">
														<td className="px-3 py-2 font-medium">{student.name}</td>
														<td className="teacher-muted px-3 py-2">{student.email ?? 'No email'}</td>
														<td className="px-3 py-2">
															<input
																className="w-28 rounded border px-2 py-1"
																type="number"
																min={0}
																max={selectedAssessment.maxGrade ?? undefined}
																value={gradesDraft[studentId] ?? ''}
																onChange={(event) => {
																	const raw = event.target.value;
																	const nextValue = raw === '' ? '' : Number(raw);
																	setGradesDraft((current) => ({ ...current, [studentId]: nextValue }));
																	setGradeErrors((current) => {
																		const next = { ...current };
																		if (raw === '') {
																			delete next[studentId];
																			return next;
																		}
																		if (!Number.isFinite(nextValue)) {
																			next[studentId] = 'Invalid number';
																			return next;
																		}
																		if (Number(nextValue) < 0) {
																			next[studentId] = 'Cannot be negative';
																			return next;
																		}
																		if (selectedAssessment.maxGrade != null && Number(nextValue) > selectedAssessment.maxGrade) {
																			next[studentId] = `Max is ${selectedAssessment.maxGrade}`;
																			return next;
																		}
																		delete next[studentId];
																		return next;
																	});
																}}
															/>
															{gradeErrors[studentId] ? (
																<div className="mt-1 text-xs text-red-600">{gradeErrors[studentId]}</div>
															) : null}
														</td>
													</tr>
												);
											})}
										</tbody>
									</table>
								</div>
							)}
						</section>
					) : null}

					<div className="space-y-4">
						{courses.map((course) => {
							const list = byCourse.get(course.id) ?? [];
							return (
								<section key={course.id} className="teacher-panel overflow-hidden rounded-[1.75rem]">
									<div className="flex items-center justify-between border-b border-slate-200/80 bg-white/50 px-4 py-3">
										<div>
											<h2 className="text-sm font-semibold">{course.name}</h2>
											<p className="teacher-muted text-xs">{course.subject}</p>
										</div>
										<span className="teacher-muted text-xs">{list.length} assessments</span>
									</div>

									<div className="p-4">
										{list.length === 0 ? (
											<div className="text-sm text-gray-500">No assessments yet.</div>
										) : (
											<div className="overflow-x-auto">
												<table className="teacher-grid-table w-full text-sm">
													<thead className="text-left text-gray-600">
														<tr>
															<th className="py-2">Title</th>
															<th className="py-2">Date</th>
															<th className="py-2">Max</th>
															<th className="py-2 text-right">Actions</th>
														</tr>
													</thead>
													<tbody>
														{list.map((assessment) => (
															<tr key={assessment.id} className="border-t border-slate-200/70">
																<td className="py-2">{assessment.title}</td>
																<td className="py-2">{assessmentDateLabel(assessment.date)}</td>
																<td className="py-2">{assessment.maxGrade ?? '—'}</td>
																<td className="py-2 text-right">
																	<button
																		className="teacher-button-secondary mr-2 rounded-lg px-2 py-1 text-xs transition hover:bg-white/90"
																		onClick={() => openAssessment(assessment)}
																	>
																		Open
																	</button>
																	<button
																		className="teacher-button-secondary rounded-lg px-2 py-1 text-xs transition hover:bg-white/90"
																		onClick={() => deleteAssessment(assessment.id)}
																	>
																		Delete
																	</button>
																</td>
															</tr>
														))}
													</tbody>
												</table>
											</div>
										)}
									</div>
								</section>
							);
						})}
					</div>
				</div>
			</AdminShell>
		</RequireAuth>
	);
}
