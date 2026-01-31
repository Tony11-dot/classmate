import { Suspense } from 'react';
import NotificationsClient from './NotificationsClient';

export const dynamic = 'force-dynamic';

export default function Page() {
  return (
    <Suspense fallback={null}>
      <NotificationsClient />
    </Suspense>
  );
}
