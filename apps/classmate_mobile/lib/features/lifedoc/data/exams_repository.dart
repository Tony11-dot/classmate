import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/exam_models.dart';

final examsRepositoryProvider = Provider<StudentExamsRepository>((ref) {
  return const StudentExamsRepository();
});

class StudentExamsRepository {
  const StudentExamsRepository();

  List<StudentExamItem> list() {
    return const <StudentExamItem>[
      StudentExamItem(
        id: 'exam-math-1',
        subject: 'Math',
        topic: 'Functions and derivatives',
        title: 'Math Midterm',
        caption:
            'Focus on derivatives, sketching, and mixed bagrut-style function questions.',
        dateLabel: '2026-03-28',
        hourLabel: '09:00',
        periodLabel: null,
        durationLabel: '90 min',
        teacher: 'Rama Khoury',
        audience: ExamAudience(
          type: ExamAudienceType.classGroup,
          label: '10th Grade • Class 10/1',
        ),
        materials: <ExamMaterialItem>[
          ExamMaterialItem(
            id: 'm1',
            name: 'Derivative review sheet',
            kind: 'PDF',
            url: null,
          ),
          ExamMaterialItem(
            id: 'm2',
            name: 'Teacher notes',
            kind: 'Text',
            url: null,
          ),
        ],
      ),
      StudentExamItem(
        id: 'exam-physics-1',
        subject: 'Physics',
        topic: 'Newton laws',
        title: 'Mechanics Quiz',
        caption:
            'Short quiz on free-body diagrams and Newton second law applications.',
        dateLabel: '2026-03-31',
        hourLabel: null,
        periodLabel: 'Period 3',
        durationLabel: '45 min',
        teacher: 'Omar Nassar',
        audience: ExamAudience(
          type: ExamAudienceType.majorGroup,
          label: '10th Physics Major',
        ),
        materials: <ExamMaterialItem>[
          ExamMaterialItem(
            id: 'p1',
            name: 'Forces summary',
            kind: 'PDF',
            url: null,
          ),
        ],
      ),
      StudentExamItem(
        id: 'exam-cs-1',
        subject: 'Computer Science',
        topic: 'C# conditions and loops',
        title: 'Programming Assessment',
        caption:
            'Expect tracing, bug fixing, and short implementation questions.',
        dateLabel: '2026-04-03',
        hourLabel: '11:30',
        periodLabel: null,
        durationLabel: '60 min',
        teacher: 'Lina Tabet',
        audience: ExamAudience(
          type: ExamAudienceType.gradeGroup,
          label: 'All 10th Grade CS Students',
        ),
        materials: <ExamMaterialItem>[
          ExamMaterialItem(
            id: 'c1',
            name: 'Loop patterns worksheet',
            kind: 'PDF',
            url: null,
          ),
          ExamMaterialItem(
            id: 'c2',
            name: 'Practice code snippets',
            kind: 'Text',
            url: null,
          ),
        ],
      ),
    ];
  }

  StudentExamItem byId(String id) {
    return list().firstWhere((e) => e.id == id, orElse: () => list().first);
  }
}
