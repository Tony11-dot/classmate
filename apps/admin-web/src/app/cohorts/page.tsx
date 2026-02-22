"use client";

import { useEffect, useState } from "react";
import { apiFetch } from "@/lib/api";
import { AdminShell } from "@/components/AdminShell";
import { RequireAuth } from "@/components/RequireAuth";

type Cohort = { id: string; name: string; grade: number };

export default function CohortsPage() {
  const [rows, setRows] = useState<Cohort[]>([]);
  const [name, setName] = useState("");
  const [grade, setGrade] = useState<number>(7);
  const [err, setErr] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function load() {
    setErr(null);
    setLoading(true);
    try {
      const res: any = await apiFetch("/admin/cohorts");
      setRows(Array.isArray(res) ? res : (res?.cohorts ?? []));
    } catch (e: any) {
      setErr(e?.message ?? "Failed to load cohorts");
    } finally {
      setLoading(false);
    }
  }

  async function create() {
    setErr(null);
    setOk(null);
    try {
      const res: any = await apiFetch("/admin/cohorts", {
        method: "POST",
        body: JSON.stringify({ name, grade }),
      });
      setOk("Created");
      setName("");
      setGrade(7);
      await load();
      return res;
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
            <h1 className="text-2xl font-semibold">Cohorts</h1>
            <button
              className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
              onClick={load}
              disabled={loading}
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
            <div className="text-sm font-medium">Create cohort</div>
            <div className="mt-3 grid gap-3 md:grid-cols-3">
              <div>
                <label className="text-xs text-gray-600">Name</label>
                <input
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Grade 9A"
                />
              </div>
              <div>
                <label className="text-xs text-gray-600">Grade</label>
                <input
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  type="number"
                  min={1}
                  max={12}
                  value={grade}
                  onChange={(e) => setGrade(Number(e.target.value))}
                />
              </div>
              <div className="flex items-end">
                <button
                  className="w-full rounded bg-black px-3 py-2 text-sm text-white hover:opacity-90 disabled:opacity-50"
                  onClick={create}
                  disabled={!name.trim()}
                >
                  Create
                </button>
              </div>
            </div>
            <div className="mt-2 text-xs text-gray-500">
              If these endpoints don’t exist yet, we’ll add them in API next.
            </div>
          </div>

          <div className="overflow-hidden rounded border">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 text-left text-gray-600">
                <tr>
                  <th className="px-3 py-2">Name</th>
                  <th className="px-3 py-2">Grade</th>
                  <th className="px-3 py-2">ID</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((c) => (
                  <tr key={c.id} className="border-t">
                    <td className="px-3 py-2">{c.name}</td>
                    <td className="px-3 py-2">{c.grade}</td>
                    <td className="px-3 py-2 font-mono text-xs">{c.id}</td>
                  </tr>
                ))}
                {rows.length === 0 && (
                  <tr className="border-t">
                    <td
                      className="px-3 py-6 text-center text-gray-500"
                      colSpan={3}
                    >
                      No cohorts yet.
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
