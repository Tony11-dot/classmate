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
        'block rounded-lg px-3 py-2 text-sm font-medium transition-colors ' +
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
    <div className="min-h-screen text-gray-950">
      <div className="flex min-h-screen flex-col gap-4 p-4 lg:flex-row lg:p-5">
        <aside className="teacher-panel teacher-panel-strong w-full rounded-4xl p-5 lg:w-72 lg:self-start">
          <div className="mb-6">
            <div className="teacher-kicker">Classmate</div>
            <div className="mt-3 text-2xl font-semibold">Teacher Workspace</div>
            <p className="teacher-muted mt-2 text-sm">
              Practical daily flow: today first, then classes, then assessments and grading.
            </p>
          </div>

          <nav className="space-y-1">
            <NavItem href="/" label="Dashboard" />
            <NavItem href="/attendance" label="Today & Attendance" />
            <NavItem href="/classrooms" label="Classrooms" />
            <NavItem href="/grades" label="Assessments & Grades" />
          </nav>

          <div className="teacher-chip mt-8 rounded-2xl p-4 text-sm">
            Live in this web workspace now: attendance, roster access, join codes, assessments, and grading.
          </div>
        </aside>

        <main className="flex-1">
          <header className="teacher-panel teacher-panel-strong flex items-center justify-between rounded-4xl px-6 py-4">
            <div>
              <div className="teacher-kicker">Teacher app</div>
              <div className="mt-1 text-sm font-medium text-gray-900">Connected to live cohorts, attendance, assessments, and grades.</div>
            </div>
            <button
              className="teacher-button-secondary rounded-xl px-3 py-2 text-sm transition hover:bg-white/90"
              onClick={() => {
                logout();
                router.replace('/login');
              }}
            >
              Logout
            </button>
          </header>

          <div className="px-1 py-4 lg:px-2">{children}</div>
        </main>
      </div>
    </div>
  );
}
