'use client';

import { useEffect, useSyncExternalStore } from 'react';
import { useRouter } from 'next/navigation';
import { TOKEN_KEY, TOKEN_EVT } from '@/lib/api';

const SSR_TOKEN_SENTINEL = '__SSR__';

function subscribe(onStoreChange: () => void) {
  const handler = () => onStoreChange();
  window.addEventListener('storage', handler);
  window.addEventListener(TOKEN_EVT, handler);
  return () => {
    window.removeEventListener('storage', handler);
    window.removeEventListener(TOKEN_EVT, handler);
  };
}

function getSnapshot() {
  try {
    return window.localStorage.getItem(TOKEN_KEY) ?? '';
  } catch {
    return '';
  }
}

function getServerSnapshot() {
  // during SSR/hydration we don't have localStorage yet
  return SSR_TOKEN_SENTINEL;
}

export function RequireAuth({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const token = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);

  useEffect(() => {
    if (token === '') router.replace('/login');
  }, [token, router]);

  if (token === SSR_TOKEN_SENTINEL) return null;
  if (!token) return null;
  return <>{children}</>;
}
