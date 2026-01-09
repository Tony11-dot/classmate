'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getToken } from '../lib/api';

export function RequireAuth({ children }: { children: React.ReactNode }) {
  const router = useRouter();

  // Initialize once from storage. No setState in effect => lint happy.
  const [token] = useState<string | null>(() => getToken());

  useEffect(() => {
    if (!token) router.replace('/login');
  }, [router, token]);

  if (!token) return null;
  return <>{children}</>;
}
