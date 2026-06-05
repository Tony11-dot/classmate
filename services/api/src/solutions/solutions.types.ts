export type CreateSolutionUploadBody = {
  subject: string;
  bookTitle: string;
  caption?: string | null;
  pageNumber: number;
  questionNumber: string;
  uploaderName?: string | null;
  uploaderInitials?: string | null;
  files: {
    kind: 'image' | 'pdf' | 'file';
    url: string;
    mimeType?: string | null;
    fileName?: string | null;
    fileSize?: number | null;
  }[];
};

export type ListSolutionsQuery = {
  subject?: string;
  bookTitle?: string;
  pageNumber?: number;
  questionNumber?: string;
  page?: number;
  limit?: number;
};

export type VerifySolutionBody = {
  verificationStatus: 'VERIFIED' | 'REJECTED' | 'UNCHECKED';
  verificationNote?: string | null;
};

export type ModerateSolutionBody = {
  moderationStatus: 'PENDING' | 'APPROVED' | 'REJECTED';
  moderationReason?: string | null;
  isDeleted?: boolean;
};

export type CreateBookBody = {
  subject: string;
  title: string;
  pages: number;
  coverUrl?: string | null;
  // When true, skip the fuzzy "similar book already exists" guard — the
  // teacher confirmed it's a genuinely different book.
  confirmDuplicate?: boolean;
};

export type UpdateBookBody = {
  title?: string;
  pages?: number;
  coverUrl?: string | null;
};

export type ReportSolutionBody = {
  reason?: string | null;
};

export type ResolveReportBody = {
  action: 'approve' | 'remove';
};
