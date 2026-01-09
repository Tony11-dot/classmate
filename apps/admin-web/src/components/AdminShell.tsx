'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { logout } from '../lib/auth';

function NavItem({ href, label }: { href: string; label: string }) {
  const pathname = usePathname();
  const active = pathname === href;
  return (
    <Link
      href={href}
      className={
        'block rounded px-3 py-2 text-sm ' +
        (active
          ? 'bg-gray-900 text-white'
          : 'text-gray-700 hover:bg-gray-100')
      }
    >
      {label}
    </Link>
  );
}

export function AdminShell({ children }: { children: React.ReactNode }) {
  const router = useRouter();

  return (
    <div className="min-h-screen bg-white">
      <div className="flex">
        <aside className="w-64 border-r p-4">
          <div className="mb-4 text-lg font-semibold">Classmate Admin</div>
          <nav className="space-y-1">
            <NavItem href="/" label="Dashboard" />
            <NavItem href="/attendance" label="Attendance" />
          </nav>
        </aside>

        <main className="flex-1">
          <header className="flex items-center justify-between border-b px-6 py-4">
            <div className="text-sm text-gray-600">Admin Web</div>
            <button
              className="rounded border px-3 py-2 text-sm hover:bg-gray-50"
              onClick={() => {
                logout();
                router.replace('/login');
              }}
            >
              Logout
            </button>
          </header>

          <div className="p-6">{children}</div>
        </main>
      </div>
    </div>
  );
}
