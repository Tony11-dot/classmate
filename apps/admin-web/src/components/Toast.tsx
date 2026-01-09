'use client';

import { useEffect, useState } from 'react';

type ToastType = 'success' | 'error' | 'info';
type ToastMsg = { id: number; type: ToastType; text: string };

let pushToast: ((t: ToastMsg) => void) | null = null;

export function toast(text: string, type: ToastType = 'info') {
  pushToast?.({ id: Date.now() + Math.random(), type, text });
}

export function ToastHost() {
  const [items, setItems] = useState<ToastMsg[]>([]);

  useEffect(() => {
    pushToast = (t) => setItems((xs) => [...xs, t]);
    return () => {
      pushToast = null;
    };
  }, []);

  useEffect(() => {
    if (items.length === 0) return;
    const id = items[0].id;
    const timer = setTimeout(() => {
      setItems((xs) => xs.filter((x) => x.id !== id));
    }, 2400);
    return () => clearTimeout(timer);
  }, [items]);

  return (
    <div className="fixed bottom-4 right-4 z-50 space-y-2">
      {items.map((t) => (
        <div
          key={t.id}
          className={
            'rounded border px-3 py-2 text-sm shadow-sm ' +
            (t.type === 'success'
              ? 'border-green-200 bg-green-50 text-green-800'
              : t.type === 'error'
                ? 'border-red-200 bg-red-50 text-red-800'
                : 'border-gray-200 bg-white text-gray-800')
          }
        >
          {t.text}
        </div>
      ))}
    </div>
  );
}
