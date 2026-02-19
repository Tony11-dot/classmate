import type { Request, Response } from "express";
import { Router } from "express";

// If your project uses a requireAuth middleware, import it here.
// Otherwise, we’ll use whatever auth wrapper you already use.
export const assignmentsRouter = Router();

/**
 * MVP in-memory storage (SAFE scaffold).
 * Replace with DB (Prisma) in the next patch.
 */
type Assignment = {
  id: string;
  title: string;
  description?: string;
  dueAt?: string;
  grade?: number | null;
  subjectId?: string | null;
  createdAt: string;
};

type Submission = {
  id: string;
  assignmentId: string;
  studentUserId: string;
  text?: string;
  mediaUrl?: string;
  createdAt: string;
};

const assignments: Assignment[] = [];
const submissions: Submission[] = [];

const now = () => new Date().toISOString();
const uid = () => Math.random().toString(16).slice(2) + Date.now().toString(16);

// GET /assignments
assignmentsRouter.get("/", (req: Request, res: Response) => {
  // TODO: enforce auth using your middleware
  res.json(assignments);
});

// POST /assignments (teacher/admin)
assignmentsRouter.post("/", (req: Request, res: Response) => {
  // TODO: enforce auth + role=teacher/admin
  const { title, description, dueAt, grade, subjectId } = req.body ?? {};
  if (!title || typeof title !== "string") {
    return res.status(400).json({ error: "title_required" });
  }

  const a: Assignment = {
    id: uid(),
    title: title.trim(),
    description: typeof description === "string" ? description.trim() : undefined,
    dueAt: typeof dueAt === "string" ? dueAt : undefined,
    grade: typeof grade === "number" ? grade : null,
    subjectId: typeof subjectId === "string" ? subjectId : null,
    createdAt: now(),
  };

  assignments.unshift(a);
  res.json(a);
});

// POST /assignments/:id/submissions (student)
assignmentsRouter.post("/:id/submissions", (req: Request, res: Response) => {
  // TODO: enforce auth + role=student
  const assignmentId = req.params.id;
  const exists = assignments.find((x) => x.id === assignmentId);
  if (!exists) return res.status(404).json({ error: "assignment_not_found" });

  const { text, mediaUrl } = req.body ?? {};

  // TEMP: until auth is wired here, accept a header to simulate student
  const studentUserId =
    (req.header("x-student-user-id") ?? "").toString().trim() || "demo-student";

  const s: Submission = {
    id: uid(),
    assignmentId,
    studentUserId,
    text: typeof text === "string" ? text.trim() : undefined,
    mediaUrl: typeof mediaUrl === "string" ? mediaUrl.trim() : undefined,
    createdAt: now(),
  };

  submissions.unshift(s);
  res.json(s);
});
