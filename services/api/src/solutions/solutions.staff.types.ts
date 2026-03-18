export type StaffSolutionActionSummary = {
  id: string;
  moderationStatus: 'PENDING' | 'APPROVED' | 'REJECTED';
  verificationStatus: 'UNCHECKED' | 'VERIFIED' | 'REJECTED';
  moderationReason?: string | null;
  verificationNote?: string | null;
  isDeleted: boolean;
};

export type StaffVerifyBody = {
  verificationStatus: 'UNCHECKED' | 'VERIFIED' | 'REJECTED';
  verificationNote?: string | null;
};

export type StaffModerateBody = {
  moderationStatus: 'PENDING' | 'APPROVED' | 'REJECTED';
  moderationReason?: string | null;
  isDeleted?: boolean;
};
