'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getToken } from '@/lib/api';

/**
 * Ensures a parent token exists (client-side).
 * - If missing: redirects to /login
 * - Returns token (string) or null while redirecting
 */
export function useParentAuth() {
  const r = useRouter();
  const [token, setToken] = useState<string | null>(null);

  useEffect(() => {
    const t = getToken();
    if (!t) {
      r.replace('/login');
      return;
    }
    setToken(t);
  }, [r]);

  return token;
}
