import Link from 'next/link';

const features = [
  {
    title: 'NOVA, the math tutor that meets students where they are',
    body:
      'Adaptive practice with hint-laddering, real LaTeX rendering, and per-topic mastery tracking. Built with a class teacher in the loop, not as a chatbot bolted on.',
  },
  {
    title: 'Run the school day from one place',
    body:
      'Attendance, grades, schedules, materials, exams, and announcements — every role gets the surface they need, no more juggling four apps.',
  },
  {
    title: 'Parents finally see the full picture',
    body:
      'Live grades, attendance trends, weak topics, and assignments without a single SMS. Built for parents who never want to chase a teacher again.',
  },
  {
    title: 'Localized for the way schools actually work',
    body:
      'English, Arabic, Hebrew, French, Russian, German, Portuguese, Turkish — every word, every tab, in production today.',
  },
];

const audiences = [
  { name: 'Students', body: 'Schedule, NOVA tutoring, assignments, grades, practice with mastery.' },
  { name: 'Parents', body: 'A single feed across all children, with weekly insights and announcements.' },
  { name: 'Teachers', body: 'Classrooms, attendance, materials, exams, assignments, and slot management.' },
  { name: 'Admins', body: 'School-wide schedule, users, cohorts, grade levels, exports, branding, billing.' },
];

export default function MarketingHome() {
  return (
    <main className="relative overflow-x-hidden">
      <header className="sticky top-0 z-30 backdrop-blur-md bg-background/70 border-b border-(--surface-border)">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-6 py-4">
          <Link href="/" className="flex items-center gap-2 text-base font-semibold tracking-tight">
            <span aria-hidden className="brand-mark inline-block h-7 w-7 rounded-xl" />
            <span>ClassMate</span>
          </Link>
          <nav className="hidden items-center gap-6 text-sm text-(--muted) md:flex">
            <a href="#features" className="hover:text-foreground">Features</a>
            <a href="#audiences" className="hover:text-foreground">Who it's for</a>
            <a href="#pricing" className="hover:text-foreground">Pricing</a>
          </nav>
          <div className="flex items-center gap-3">
            <Link
              href="/app"
              className="rounded-full border border-(--surface-border) px-4 py-2 text-sm font-medium text-foreground transition hover:bg-white/60"
            >
              Sign in
            </Link>
            <Link
              href="/app"
              className="teacher-button-primary rounded-full px-4 py-2 text-sm font-medium"
            >
              Open the app
            </Link>
          </div>
        </div>
      </header>

      <section className="mx-auto max-w-6xl px-6 pt-20 pb-24 md:pt-32 md:pb-32">
        <div className="grid items-center gap-12 md:grid-cols-[1.05fr_0.95fr]">
          <div>
            <div className="teacher-kicker">For schools, teachers, parents, students</div>
            <h1 className="mt-3 text-5xl font-semibold leading-[1.05] tracking-tight md:text-6xl">
              One school app.<br />
              <span className="text-(--accent-strong)">Five roles.</span><br />
              Zero friction.
            </h1>
            <p className="mt-6 max-w-xl text-lg text-(--muted)">
              ClassMate is the AI-native school platform that replaces the eight half-broken
              apps your school is paying for today — built mobile-first, fully localized,
              and rebuilt every week from real classroom use.
            </p>
            <div className="mt-8 flex flex-wrap items-center gap-3">
              <Link
                href="/app"
                className="teacher-button-primary rounded-full px-6 py-3 text-base font-medium"
              >
                Open the web app →
              </Link>
              <a
                href="#features"
                className="rounded-full border border-(--surface-border) bg-white/60 px-6 py-3 text-base font-medium text-foreground hover:bg-white/90"
              >
                See what's inside
              </a>
            </div>
            <div className="mt-8 flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-(--muted)">
              <span>iOS · Android · Web</span>
              <span aria-hidden>·</span>
              <span>8 languages</span>
              <span aria-hidden>·</span>
              <span>Built in 2026</span>
            </div>
          </div>

          <div className="relative">
            <div aria-hidden className="hero-glow pointer-events-none absolute -inset-10 -z-10 rounded-4xl opacity-60 blur-3xl" />
            <div className="teacher-panel mx-auto w-full max-w-sm rounded-4xl p-6 shadow-2xl">
              <div className="teacher-kicker">Today · Period 3</div>
              <div className="mt-3 text-2xl font-semibold leading-tight">
                Algebra II · 11B
              </div>
              <div className="mt-1 text-sm text-(--muted)">
                Room 204 · Ms. Haddad
              </div>
              <div className="mt-5 space-y-2 text-sm">
                {['Quadratic formula refresh', 'Practice set: 12 questions', 'Exit ticket: 3 questions'].map((row) => (
                  <div key={row} className="flex items-center gap-2 rounded-2xl border border-(--surface-border) bg-white/70 px-3 py-2">
                    <span aria-hidden className="dot-accent h-2 w-2 rounded-full" />
                    <span>{row}</span>
                  </div>
                ))}
              </div>
              <div className="mt-5 rounded-2xl bg-(--accent-soft) px-4 py-3 text-sm text-(--accent-strong)">
                NOVA: &quot;I noticed 3 students missed the discriminant step — want me to queue a 2-question warmup for next class?&quot;
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="features" className="mx-auto max-w-6xl px-6 py-24">
        <div className="teacher-kicker">Why teams switch</div>
        <h2 className="mt-3 max-w-3xl text-4xl font-semibold leading-tight tracking-tight">
          Built for the classroom, not the brochure.
        </h2>
        <div className="mt-12 grid gap-6 md:grid-cols-2">
          {features.map((feature) => (
            <article key={feature.title} className="teacher-panel rounded-3xl p-6">
              <h3 className="text-lg font-semibold">{feature.title}</h3>
              <p className="mt-2 text-sm text-(--muted)">{feature.body}</p>
            </article>
          ))}
        </div>
      </section>

      <section id="audiences" className="mx-auto max-w-6xl px-6 py-24">
        <div className="teacher-kicker">One app, every role</div>
        <h2 className="mt-3 max-w-3xl text-4xl font-semibold leading-tight tracking-tight">
          A surface for everyone in the school day.
        </h2>
        <div className="mt-12 grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {audiences.map((audience) => (
            <div key={audience.name} className="teacher-panel rounded-3xl p-5">
              <div className="teacher-kicker">{audience.name}</div>
              <p className="mt-3 text-sm text-(--foreground)/85">{audience.body}</p>
            </div>
          ))}
        </div>
      </section>

      <section id="pricing" className="mx-auto max-w-4xl px-6 py-24 text-center">
        <div className="teacher-kicker">Pricing</div>
        <h2 className="mt-3 text-4xl font-semibold tracking-tight">
          Free to try. Pay per student, per month, once you go live.
        </h2>
        <p className="mt-4 text-base text-(--muted)">
          Per-school pricing with NOVA tokens included. Talk to us about district rollouts.
        </p>
        <div className="mt-8 flex flex-wrap justify-center gap-3">
          <Link
            href="/app"
            className="teacher-button-primary rounded-full px-6 py-3 text-base font-medium"
          >
            Start free →
          </Link>
          <a
            href="mailto:hello@classmateapp.org"
            className="rounded-full border border-(--surface-border) bg-white/60 px-6 py-3 text-base font-medium hover:bg-white/90"
          >
            Talk to the team
          </a>
        </div>
      </section>

      <footer className="border-t border-(--surface-border) py-10 text-center text-sm text-(--muted)">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-3 px-6 md:flex-row">
          <div>© {new Date().getFullYear()} ClassMate.</div>
          <div className="flex gap-6">
            <Link href="/app" className="hover:text-foreground">Open the app</Link>
            <a href="mailto:hello@classmateapp.org" className="hover:text-foreground">Contact</a>
          </div>
        </div>
      </footer>
    </main>
  );
}
