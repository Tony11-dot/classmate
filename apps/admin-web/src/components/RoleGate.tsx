'use client';

import { useEffect, useState } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import { getMe } from '../lib/me';

type Props = {
  allow?: string[];
  children: React.ReactNode;
};

export default function RoleGate({ allow, children }: Props) {
  const r = useRouter();
  const path = usePathname();
  const [ok, setOk] = useState<boolean | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const me = await getMe();
        const role = me?.user?.role ?? null;

        if (!me?.user) {
          setOk(false);
          if (path !== '/login') r.replace('/login');
          return;
        }

        if (allow && allow.length > 0 && (!role || !allow.includes(role))) {
          setOk(false);
          r.replace('/');
          return;
        }

        setOk(true);
      } catch {
        setOk(false);
        if (path !== '/login') r.replace('/login');
      }
    })();
  }, [r, path, allow]);

  if (ok === null) return null;
  if (!ok) return null;
  return <>{children}</>;
}
