import bcrypt from "bcryptjs";
import { prisma } from "../src/lib/prisma";
import { Prisma } from "@prisma/client";

const SCHOOL_ID = "demo";

const hasModel = (name: string) => Object.prototype.hasOwnProperty.call(prisma as any, name);

const dmmfModel = (name: string) =>
  Prisma.dmmf.datamodel.models.find((m) => m.name === name) ?? null;

const modelFields = (name: string) => new Set((dmmfModel(name)?.fields ?? []).map((f) => f.name));

const pick = (modelName: string, data: Record<string, any>) => {
  const f = modelFields(modelName);
  const out: Record<string, any> = {};
  for (const [k, v] of Object.entries(data)) if (f.has(k) && v !== undefined) out[k] = v;
  return out;
};

const ensureRequired = (modelName: string, data: Record<string, any>) => {
  const m = dmmfModel(modelName);
  if (!m) return data;
  for (const f of m.fields) {
    if (f.kind !== "scalar") continue;
    if (!f.isRequired) continue;
    if (f.hasDefaultValue) continue;
    if (f.isId) continue;
    if (data[f.name] !== undefined) continue;

    // conservative defaults
    if (f.type === "String") data[f.name] = "";
    else if (f.type === "Int") data[f.name] = 0;
    else if (f.type === "Boolean") data[f.name] = false;
    else if (f.type === "DateTime") data[f.name] = new Date();
  }
  return data;
};

const mkUser = async (role: any, fullName: string, email: string, pw: string) => {
  email = email.toLowerCase();
  const passwordHash = await bcrypt.hash(pw, 10);

  return (prisma as any).user.upsert({
    where: { schoolId_email: { schoolId: SCHOOL_ID, email } },
    update: { fullName, role, passwordHash },
    create: { schoolId: SCHOOL_ID, fullName, email, role, passwordHash },
    select: { id: true, email: true, role: true, fullName: true, schoolId: true },
  });
};

async function ensureSchool() {
  if (!hasModel("school")) return;

  const data = ensureRequired(
    "School",
    pick("School", {
      id: SCHOOL_ID,
      schoolId: SCHOOL_ID,
      name: "Demo School",
      title: "Demo School",
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
  );

  // prefer upsert by id if exists; otherwise just create-if-missing
  const f = modelFields("School");
  if (f.has("id")) {
    await (prisma as any).school.upsert({
      where: { id: SCHOOL_ID },
      update: pick("School", { name: "Demo School", title: "Demo School" }),
      create: data,
    });
  } else if (f.has("schoolId")) {
    const ex = await (prisma as any).school.findFirst({ where: { schoolId: SCHOOL_ID } });
    if (!ex) await (prisma as any).school.create({ data });
  }
}

async function ensureTeacherRow(userId: string) {
  if (!hasModel("teacher")) return null;
  const ex = await (prisma as any).teacher.findFirst({ where: pick("Teacher", { userId }) });
  if (ex) return ex;

  const data = ensureRequired(
    "Teacher",
    pick("Teacher", {
      userId,
      schoolId: SCHOOL_ID,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
  );
  return (prisma as any).teacher.create({ data });
}

async function ensureParentRow(userId: string) {
  if (!hasModel("parent")) return null;
  const ex = await (prisma as any).parent.findFirst({ where: pick("Parent", { userId }) });
  if (ex) return ex;

  const data = ensureRequired(
    "Parent",
    pick("Parent", {
      userId,
      schoolId: SCHOOL_ID,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
  );
  return (prisma as any).parent.create({ data });
}

async function ensureStudentRow(userId: string) {
  if (!hasModel("student")) return null;
  const ex = await (prisma as any).student.findFirst({ where: pick("Student", { userId }) });
  if (ex) return ex;

  const data = ensureRequired(
    "Student",
    pick("Student", {
      userId,
      schoolId: SCHOOL_ID,
      grade: 9,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
  );
  return (prisma as any).student.create({ data });
}

async function main() {
  if (!hasModel("user")) throw new Error("Prisma Client missing model: user");

  await ensureSchool();

  const admin   = await mkUser("ADMIN",   "Admin Demo",   "admin@demo.com",   "admin123");
  const teacher = await mkUser("TEACHER", "Teacher Demo", "teacher@demo.com", "teacher123");
  const parent  = await mkUser("PARENT",  "Parent Demo",  "parent@demo.com",  "parent123");
  const student = await mkUser("STUDENT", "Student Demo", "student@demo.com", "student123");

  const teacherRow = await ensureTeacherRow(teacher.id);
  const parentRow  = await ensureParentRow(parent.id);
  const studentRow = await ensureStudentRow(student.id);

  // ClassRoom path
  let classRoomId: string | null = null;
  if (hasModel("classRoom")) {
    const ex = await (prisma as any).classRoom.findFirst({ where: pick("ClassRoom", { schoolId: SCHOOL_ID }) });
    const cr =
      ex ??
      (await (prisma as any).classRoom.create({
        data: ensureRequired(
          "ClassRoom",
          pick("ClassRoom", { schoolId: SCHOOL_ID, name: "9A", grade: 9, createdAt: new Date(), updatedAt: new Date() }),
        ),
      }));
    classRoomId = cr.id;

    if (hasModel("teachingAssignment") && teacherRow) {
      const where = pick("TeachingAssignment", { classId: cr.id, teacherId: teacherRow.id });
      const create = ensureRequired("TeachingAssignment", pick("TeachingAssignment", { classId: cr.id, teacherId: teacherRow.id, createdAt: new Date() }));
      const unique = { classId_teacherId: { classId: cr.id, teacherId: teacherRow.id } };
      try {
        await (prisma as any).teachingAssignment.upsert({ where: unique, update: {}, create });
      } catch {
        // ignore if unique shape differs; fall back to create-if-missing
        const exists = await (prisma as any).teachingAssignment.findFirst({ where });
        if (!exists) await (prisma as any).teachingAssignment.create({ data: create });
      }
    }

    if (hasModel("enrollment") && studentRow) {
      const where = pick("Enrollment", { classId: cr.id, studentId: studentRow.id });
      const create = ensureRequired("Enrollment", pick("Enrollment", { classId: cr.id, studentId: studentRow.id, createdAt: new Date() }));
      const unique = { classId_studentId: { classId: cr.id, studentId: studentRow.id } };
      try {
        await (prisma as any).enrollment.upsert({ where: unique, update: {}, create });
      } catch {
        const exists = await (prisma as any).enrollment.findFirst({ where });
        if (!exists) await (prisma as any).enrollment.create({ data: create });
      }
    }
  }

  // Parent-child link
  if (hasModel("parentChild")) {
    // likely parentId/childId are USER ids (based on your API route usage earlier)
    const where = pick("ParentChild", { parentId: parent.id, childId: student.id });
    const create = ensureRequired("ParentChild", pick("ParentChild", { parentId: parent.id, childId: student.id, status: "APPROVED", createdAt: new Date(), updatedAt: new Date() }));
    const unique = { parentId_childId: { parentId: parent.id, childId: student.id } };
    try {
      await (prisma as any).parentChild.upsert({ where: unique, update: {}, create });
    } catch {
      const exists = await (prisma as any).parentChild.findFirst({ where });
      if (!exists) await (prisma as any).parentChild.create({ data: create });
    }
  } else if (hasModel("parentStudent") && parentRow && studentRow) {
    // join table between Parent.id and Student.id
    const where = pick("ParentStudent", { parentId: parentRow.id, studentId: studentRow.id });
    const create = ensureRequired("ParentStudent", pick("ParentStudent", { parentId: parentRow.id, studentId: studentRow.id, createdAt: new Date() }));
    const unique = { parentId_studentId: { parentId: parentRow.id, studentId: studentRow.id } };
    try {
      await (prisma as any).parentStudent.upsert({ where: unique, update: {}, create });
    } catch {
      const exists = await (prisma as any).parentStudent.findFirst({ where });
      if (!exists) await (prisma as any).parentStudent.create({ data: create });
    }
  }

  console.log({
    schoolId: SCHOOL_ID,
    admin,
    teacher,
    parent,
    student,
    teacherRowId: teacherRow?.id ?? null,
    parentRowId: parentRow?.id ?? null,
    studentRowId: studentRow?.id ?? null,
    classRoomId,
    models: Object.keys(prisma as any).filter((k) => (prisma as any)[k]?.findFirst || (prisma as any)[k]?.findMany).sort(),
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
