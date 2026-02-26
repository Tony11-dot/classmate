export function currentUserId(u: any): string {
  const id = u?.sub ?? u?.userId ?? u?.id;
  if (!id) throw new Error('Missing user id (sub/userId/id)');
  return String(id);
}
