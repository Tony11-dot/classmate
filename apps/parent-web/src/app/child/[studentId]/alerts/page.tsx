'use client';

import Link from 'next/link';
import { useEffect, useMemo, useState } from 'react';
import { useParams } from 'next/navigation';

// Adjust this import path if your API file is different:
import { getAlertSettings, updateAlertSettings } from '@/lib/api';

type Settings = {
  id?: string;
  ownerId?: string;
  studentId: string;
  minGrade: number;
  maxAbsences: number;
  maxLates: number;
};

export default function AlertsSettingsPage() {
  const params = useParams();
  const studentId = String(params.studentId);

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const [defaults, setDefaults] = useState<Settings | null>(null);
  const [settings, setSettings] = useState<Settings | null>(null);

  const dirty = useMemo(() => {
    if (!defaults || !settings) return false;
    return (
      settings.minGrade !== defaults.minGrade ||
      settings.maxAbsences !== defaults.maxAbsences ||
      settings.maxLates !== defaults.maxLates
    );
  }, [defaults, settings]);

  useEffect(() => {
    (async () => {
      try {
        setErr(null);
        setLoading(true);
        const res = await getAlertSettings(studentId);
        setSettings(res.settings);
        setDefaults(res.defaults);
      } catch (e: any) {
        setErr(e?.message ?? 'Failed to load alert settings');
      } finally {
        setLoading(false);
      }
    })();
  }, [studentId]);

  async function save() {
    if (!settings) return;
    try {
      setErr(null);
      setSaving(true);
      const res = await updateAlertSettings({
        studentId,
        minGrade: settings.minGrade,
        maxAbsences: settings.maxAbsences,
        maxLates: settings.maxLates,
      });
      setSettings(res.settings);
      // keep defaults as returned defaults (unchanged)
    } catch (e: any) {
      setErr(e?.message ?? 'Failed to save');
    } finally {
      setSaving(false);
    }
  }

  function resetToDefaults() {
    if (!defaults) return;
    setSettings({ ...defaults, studentId });
  }

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Alert Settings</h1>
        <Link className="rounded-md border px-3 py-2 text-sm" href={`/child/${studentId}`}>
          Back
        </Link>
      </div>

      {loading && <div className="mt-6 opacity-70">Loading…</div>}
      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      {!loading && settings && (
        <div className="mt-6 space-y-6">
          <div className="rounded-lg border p-4">
            <div className="font-medium">Minimum Grade</div>
            <div className="text-sm opacity-70 mt-1">
              Alert when a grade is below this number.
            </div>

            <div className="mt-3 flex items-center gap-4">
              <input
                className="w-full"
                type="range"
                min={0}
                max={100}
                value={settings.minGrade}
                onChange={(e) =>
                  setSettings((s) =>
                    s ? { ...s, minGrade: Number(e.target.value) } : s
                  )
                }
              />
              <input
                className="w-24 rounded-md border px-2 py-1 text-sm"
                type="number"
                min={0}
                max={100}
                value={settings.minGrade}
                onChange={(e) =>
                  setSettings((s) =>
                    s ? { ...s, minGrade: Number(e.target.value) } : s
                  )
                }
              />
            </div>
          </div>

          <div className="rounded-lg border p-4">
            <div className="font-medium">Max Absences</div>
            <div className="text-sm opacity-70 mt-1">
              Alert after this many absences.
            </div>

            <div className="mt-3 flex items-center gap-4">
              <input
                className="w-full"
                type="range"
                min={0}
                max={50}
                value={settings.maxAbsences}
                onChange={(e) =>
                  setSettings((s) =>
                    s ? { ...s, maxAbsences: Number(e.target.value) } : s
                  )
                }
              />
              <input
                className="w-24 rounded-md border px-2 py-1 text-sm"
                type="number"
                min={0}
                value={settings.maxAbsences}
                onChange={(e) =>
                  setSettings((s) =>
                    s ? { ...s, maxAbsences: Number(e.target.value) } : s
                  )
                }
              />
            </div>
          </div>

          <div className="rounded-lg border p-4">
            <div className="font-medium">Max Lates</div>
            <div className="text-sm opacity-70 mt-1">
              Alert after this many late arrivals.
            </div>

            <div className="mt-3 flex items-center gap-4">
              <input
                className="w-full"
                type="range"
                min={0}
                max={50}
                value={settings.maxLates}
                onChange={(e) =>
                  setSettings((s) =>
                    s ? { ...s, maxLates: Number(e.target.value) } : s
                  )
                }
              />
              <input
                className="w-24 rounded-md border px-2 py-1 text-sm"
                type="number"
                min={0}
                value={settings.maxLates}
                onChange={(e) =>
                  setSettings((s) =>
                    s ? { ...s, maxLates: Number(e.target.value) } : s
                  )
                }
              />
            </div>
          </div>

          <div className="flex items-center justify-between">
            <div className="text-sm opacity-70">
              {dirty ? 'Custom settings (changed from defaults)' : 'Using defaults'}
            </div>

            <div className="flex gap-2">
              <button
                className="rounded-md border px-3 py-2 text-sm"
                onClick={resetToDefaults}
                disabled={!dirty || saving}
              >
                Reset
              </button>

              <button
                className="rounded-md border px-3 py-2 text-sm"
                onClick={save}
                disabled={saving}
              >
                {saving ? 'Saving…' : 'Save'}
              </button>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}
