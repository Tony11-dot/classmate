import { tutorSdk } from "@classmate/sdk";

const baseUrl =
  process.env.NEXT_PUBLIC_API_BASE_URL ??
  process.env.NEXT_PUBLIC_API_BASE ??
  "http://127.0.0.1:3002/api";

export const api = {
  tutor: tutorSdk(baseUrl),
};

export type { ApiOkOf } from "@classmate/sdk";
