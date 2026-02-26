import type { ReactNode } from 'react';
import RoleGate from '../../components/RoleGate';

export default function ProtectedLayout({ children }: { children: ReactNode }) {
  return <RoleGate>{children}</RoleGate>;
}
