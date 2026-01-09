import { RequireAuth } from '../components/RequireAuth';
import { AdminShell } from '../components/AdminShell';

export default function HomePage() {
  return (
    <RequireAuth>
      <AdminShell>
        <h1 className="text-2xl font-semibold">Dashboard</h1>
        <p className="mt-2 text-gray-700">
          Next step: wire real admin panels (attendance, schedule overrides,
          cohorts, etc.).
        </p>
      </AdminShell>
    </RequireAuth>
  );
}
