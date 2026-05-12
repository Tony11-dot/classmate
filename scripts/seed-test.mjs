#!/usr/bin/env node
/**
 * seed-test.mjs
 *
 * Creates minimal deterministic test data for the E2E suite:
 *   • 1 school   (idempotent — reuses if name already exists)
 *   • 1 teacher  (dev-token-teacher1@classmate.app — already exists)
 *   • 1 student  (dev-token-student1@classmate.app — already exists)
 *   • 1 cohort   assigned to the school
 *   • student enrolled in cohort
 *   • 1 classroom owned by teacher, student as member
 *   • 1 open assignment in that classroom
 *
 * Outputs: JSON with ids for use by tests.
 * Usage:  node scripts/seed-test.mjs [API_BASE]
 *         npm run seed:test
 */

import http from 'http';

const BASE = (process.argv[2] ?? process.env.E2E_API_BASE_URL ?? 'http://127.0.0.1:3001')
  .replace(/\/$/, '');

const TEACHER = 'dev-token-teacher1@classmate.app';
const STUDENT = 'dev-token-student1@classmate.app';
const ADMIN   = 'dev-token-admin@classmate.app';

async function req(method, path, token, body) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const url = new URL(path, BASE);
    const options = {
      hostname: url.hostname,
      port: url.port || 3001,
      path: url.pathname + url.search,
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {}),
      },
    };
    const r = http.request(options, (res) => {
      let raw = '';
      res.on('data', c => raw += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(raw) }); }
        catch { resolve({ status: res.statusCode, body: raw }); }
      });
    });
    r.on('error', reject);
    if (data) r.write(data);
    r.end();
  });
}

async function seed() {
  // ── 1. Get or create school ───────────────────────────────────────────────
  let schoolId;
  {
    const me = await req('GET', '/auth/me', ADMIN);
    if (me.body?.schoolId) {
      schoolId = me.body.schoolId;
      console.log('↩  reusing school:', schoolId);
    } else {
      const s = await req('POST', '/admin/schools', ADMIN, { name: 'E2E Test School' });
      if (s.status !== 201 && s.status !== 200) {
        // List existing and use first
        const list = await req('GET', '/admin/schools', ADMIN);
        schoolId = list.body?.schools?.[0]?.id;
        if (!schoolId) throw new Error(`Cannot create/find school: ${JSON.stringify(s.body)}`);
        console.log('↩  found existing school:', schoolId);
      } else {
        schoolId = s.body.school?.id ?? s.body.id;
        console.log('✅ created school:', schoolId);
      }
    }
  }

  // ── 2. Assign school to teacher + student dev users ───────────────────────
  for (const [tok, label] of [[TEACHER, 'teacher'], [STUDENT, 'student']]) {
    const me = await req('GET', '/auth/me', tok);
    const userId = me.body?.id;
    if (userId && !me.body?.schoolId) {
      await req('POST', `/admin/schools/${schoolId}/assign-user`, ADMIN, { userId });
      console.log(`✅ assigned ${label} (${userId}) → school`);
    } else {
      console.log(`↩  ${label} already has school or not found`);
    }
  }

  // ── 3. Create cohort ──────────────────────────────────────────────────────
  let cohortId;
  {
    const cohortName = 'E2E-Test-Cohort-10';
    // Try to find existing first
    const list = await req('GET', '/admin/cohorts', ADMIN);
    const existing = list.body?.cohorts?.find(c => c.name === cohortName);
    if (existing) {
      cohortId = existing.id;
      console.log('↩  reusing cohort:', cohortId);
    } else {
      const r = await req('POST', '/admin/cohorts', ADMIN, { name: cohortName, grade: 10 });
      cohortId = r.body?.id ?? r.body?.cohort?.id;
      if (!cohortId) throw new Error(`Cannot create cohort: ${JSON.stringify(r.body)}`);
      console.log('✅ created cohort:', cohortId);
    }
  }

  // ── 4. Enroll student in cohort ───────────────────────────────────────────
  {
    const studentMe = await req('GET', '/auth/me', STUDENT);
    const studentUserId = studentMe.body?.id;
    if (!studentUserId) throw new Error('Cannot find student user id');

    const r = await req('POST', `/admin/cohorts/${cohortId}/students`, ADMIN, {
      studentIds: [studentUserId],
    });
    if (r.status === 200 || r.status === 201) {
      console.log('✅ enrolled student in cohort');
    } else {
      console.log('↩  student already enrolled (or error):', r.status);
    }
  }

  // ── 5. Create classroom owned by teacher ──────────────────────────────────
  let classroomId;
  {
    const existing = await req('GET', '/teacher/classrooms', TEACHER);
    const found = existing.body?.classrooms?.find(c => c.name === 'E2E Classroom');
    if (found) {
      classroomId = found.id;
      console.log('↩  reusing classroom:', classroomId);
    } else {
      const r = await req('POST', '/teacher/classrooms', TEACHER, {
        name: 'E2E Classroom',
        subject: 'Mathematics',
      });
      classroomId = r.body?.classroom?.id;
      if (!classroomId) throw new Error(`Cannot create classroom: ${JSON.stringify(r.body)}`);
      console.log('✅ created classroom:', classroomId);
    }
  }

  // ── 6. Add student as classroom member ────────────────────────────────────
  {
    const studentMe = await req('GET', '/auth/me', STUDENT);
    const studentUserId = studentMe.body?.id;
    const r = await req('POST', `/teacher/classrooms/${classroomId}/members`, TEACHER, {
      studentIds: [studentUserId],
    });
    if (r.status === 200 || r.status === 201) {
      console.log('✅ added student to classroom');
    } else {
      console.log('↩  student already in classroom or error:', r.status, r.body?.message ?? '');
    }
  }

  // ── 7. Create open assignment in classroom ────────────────────────────────
  let assignmentId;
  {
    const existing = await req('GET', `/teacher/classrooms/${classroomId}/assignments`, TEACHER);
    const items = existing.body?.items ?? existing.body ?? [];
    const found = (Array.isArray(items) ? items : []).find(a => a.title === 'E2E Assignment');
    if (found) {
      assignmentId = found.id;
      console.log('↩  reusing assignment:', assignmentId);
    } else {
      const r = await req(
        'POST',
        `/teacher/classrooms/${classroomId}/assignments`,
        TEACHER,
        {
          title: 'E2E Assignment',
          body: 'This assignment was created by the E2E seed script.',
          dueAt: new Date(Date.now() + 7 * 86400000).toISOString(),
        }
      );
      assignmentId = r.body?.item?.id ?? r.body?.id;
      if (!assignmentId) throw new Error(`Cannot create assignment: ${JSON.stringify(r.body)}`);
      console.log('✅ created assignment:', assignmentId);
    }
  }

  // ── Done ──────────────────────────────────────────────────────────────────
  const result = { schoolId, cohortId, classroomId, assignmentId };
  console.log('\n✅ seed complete:', JSON.stringify(result, null, 2));

  // Write IDs to a temp file so tests can read them
  const fs = await import('fs');
  fs.writeFileSync('/tmp/classmate-e2e-seed.json', JSON.stringify(result));
  console.log('📄 ids written to /tmp/classmate-e2e-seed.json');

  return result;
}

seed().catch(e => { console.error('❌ seed failed:', e.message); process.exit(1); });
