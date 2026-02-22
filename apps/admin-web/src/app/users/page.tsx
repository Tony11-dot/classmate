"use client";

import { useEffect, useState } from "react";
import { apiFetch } from "@/lib/api";
import { AdminShell } from "@/components/AdminShell";
import { RequireAuth } from "@/components/RequireAuth";

type UserRow = {
  id: string;
  email: string;
  roles: string[];
  name?: string | null;
};

export default function UsersPage() {
  const [rows, setRows] = useState<UserRow[]>([]);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("Passw0rd!");
  const [role, setRole] = useState("ADMIN");
  const [name, setName] = useState("");
  const [err, setErr] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);

  async function load() {
    setErr(null);
    try {
      const res: any = await apiFetch("/admin/users");
      setRows(Array.isArray(res) ? res : (res?.users ?? []));
    } catch (e: any) {
      setErr(e?.message ?? "Failed to load users");
    }
  }

  async function create() {
    setErr(null);
    setOk(null);
    try {
      await apiFetch("/admin/users", {
        method: "POST",
        body: JSON.stringify({ email, password, roles: [role], name }),
      });
      setOk("Created");
      setEmail("");
      setName("");
      await load();
    } catch (e: any) {
      setErr(e?.message ?? "Create failed");
    }
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <RequireAuth>
      <AdminShell>
        <div className="space-y-4 p-6">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-semibold">Users</h1>
            <button
              className="rounded border px-3 py-2 text-sm hover:bg-gray-50"
              onClick={load}
            >
              Refresh
            </button>
          </div>

          {err && (
            <div className="rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">
              {err}
            </div>
          )}
          {ok && (
            <div className="rounded border border-green-200 bg-green-50 p-3 text-sm text-green-700">
              {ok}
            </div>
          )}

          <div className="rounded border p-4">
            <div className="text-sm font-medium">Create user</div>
            <div className="mt-3 grid gap-3 md:grid-cols-4">
              <div>
                <label className="text-xs text-gray-600">Email</label>
                <input
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="new@user.com"
                />
              </div>
              <div>
                <label className="text-xs text-gray-600">Password</label>
                <input
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
              </div>
              <div>
                <label className="text-xs text-gray-600">Role</label>
                <select
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                >
                  <option value="ADMIN">ADMIN</option>
                  <option value="TEACHER">TEACHER</option>
                  <option value="STUDENT">STUDENT</option>
                  <option value="PARENT">PARENT</option>
                </select>
              </div>
              <div>
                <label className="text-xs text-gray-600">Name</label>
                <input
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Tony"
                />
              </div>
            </div>
            <div className="mt-3">
              <button
                className="rounded bg-black px-3 py-2 text-sm text-white hover:opacity-90 disabled:opacity-50"
                onClick={create}
                disabled={!email.trim()}
              >
                Create
              </button>
            </div>
            <div className="mt-2 text-xs text-gray-500">
              If /admin/users doesn’t exist yet, we add it in API next.
            </div>
          </div>

          <div className="overflow-hidden rounded border">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 text-left text-gray-600">
                <tr>
                  <th className="px-3 py-2">Email</th>
                  <th className="px-3 py-2">Roles</th>
                  <th className="px-3 py-2">ID</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((u) => (
                  <tr key={u.id} className="border-t">
                    <td className="px-3 py-2">{u.email}</td>
                    <td className="px-3 py-2">{(u.roles ?? []).join(", ")}</td>
                    <td className="px-3 py-2 font-mono text-xs">{u.id}</td>
                  </tr>
                ))}
                {rows.length === 0 && (
                  <tr className="border-t">
                    <td
                      className="px-3 py-6 text-center text-gray-500"
                      colSpan={3}
                    >
                      No users found.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </AdminShell>
    </RequireAuth>
  );
}
