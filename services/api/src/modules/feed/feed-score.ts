export function computeFeedRankingScore(input: {
  likeCount: number;
  commentCount: number;
  repostCount: number;
  createdAt: Date | string;
  teacherPick?: boolean;
  bestSolution?: boolean;
}) {
  const createdAt =
    input.createdAt instanceof Date ? input.createdAt : new Date(input.createdAt);

  const ageHours = Math.max(
    0,
    (Date.now() - createdAt.getTime()) / (1000 * 60 * 60),
  );

  const engagement =
    input.likeCount * 3 +
    input.commentCount * 5 +
    input.repostCount * 4;

  const teacherPickBonus = input.teacherPick ? 20 : 0;
  const bestSolutionBonus = input.bestSolution ? 15 : 0;
  const recencyBonus = (Math.max(0, 24 - ageHours) / 24) * 8;

  return engagement + teacherPickBonus + bestSolutionBonus + recencyBonus;
}
