// Year
document.getElementById('year').textContent = new Date().getFullYear();

// ── Theme toggle (saved choice → system) ──
const root = document.documentElement;
const saved = localStorage.getItem('cm-theme');
if (saved) {
  root.setAttribute('data-theme', saved);
} else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
  root.setAttribute('data-theme', 'dark');
}
const toggle = document.getElementById('themeToggle');
function syncToggleIcon() {
  toggle.textContent = root.getAttribute('data-theme') === 'dark' ? '☀️' : '🌙';
}
syncToggleIcon();
toggle.addEventListener('click', () => {
  const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
  root.setAttribute('data-theme', next);
  localStorage.setItem('cm-theme', next);
  syncToggleIcon();
});

// ── Reveal on scroll ──
const io = new IntersectionObserver(
  (entries) => entries.forEach((e) => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } }),
  { threshold: 0.12 }
);
document.querySelectorAll('.reveal').forEach((el) => io.observe(el));

// ── Role tabs ──
const tabs = document.querySelectorAll('.role-tab');
const panels = document.querySelectorAll('.role-panel');
tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    const role = tab.dataset.role;
    tabs.forEach((t) => t.classList.toggle('active', t === tab));
    panels.forEach((p) => p.classList.toggle('active', p.dataset.role === role));
  });
});

// ── Hero placeholder → real screenshot swap (if file exists) ──
document.querySelectorAll('.ph[data-shot]').forEach((el) => {
  const name = el.getAttribute('data-shot');
  const img = new Image();
  img.onload = () => {
    el.style.backgroundImage = `url("assets/${name}-light.png")`;
    el.classList.remove('ph');
    const label = el.querySelector('.ph-label');
    if (label) label.remove();
  };
  img.src = `assets/${name}-light.png`;
});

// ── Sticky showcase: crossfade the phone's screenshot as steps scroll in ──
const shots = Array.from(document.querySelectorAll('.showcase-shot'));
const steps = Array.from(document.querySelectorAll('.showcase-step'));
if (shots.length && steps.length) {
  function setStep(n) {
    shots.forEach((s) => s.classList.toggle('is-active', s.dataset.step === String(n)));
    steps.forEach((s) => s.classList.toggle('is-active', s.dataset.step === String(n)));
  }
  const stepIO = new IntersectionObserver(
    (entries) => {
      // Pick the most-visible step near the viewport middle.
      let best = null;
      entries.forEach((e) => {
        if (e.isIntersecting && (!best || e.intersectionRatio > best.intersectionRatio)) best = e;
      });
      if (best) setStep(best.target.dataset.step);
    },
    // A single trigger LINE at the viewport middle — exactly one step
    // straddles it at a time, so the active step never flickers between two
    // (the cause of the glitchy feel on phones).
    { rootMargin: '-50% 0px -50% 0px', threshold: 0 }
  );
  steps.forEach((s) => stepIO.observe(s));
}

// ── Scroll-driven effects: progress bar, nav state, hero parallax ──
const progress = document.getElementById('scrollProgress');
const nav = document.getElementById('nav');
const heroPhone = document.querySelector('.phone-hero');
const heroGlow = document.querySelector('.hero-glow');
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

let ticking = false;
function onScroll() {
  if (ticking) return;
  ticking = true;
  requestAnimationFrame(() => {
    const y = window.scrollY || window.pageYOffset;
    const docH = document.documentElement.scrollHeight - window.innerHeight;
    if (progress) progress.style.transform = `scaleX(${docH > 0 ? y / docH : 0})`;
    if (nav) nav.classList.toggle('scrolled', y > 8);
    if (!reduceMotion) {
      if (heroPhone) heroPhone.style.transform = `translateY(${y * -0.08}px) rotate(-3deg)`;
      if (heroGlow) heroGlow.style.transform = `translateY(${y * 0.12}px)`;
    }
    ticking = false;
  });
}
window.addEventListener('scroll', onScroll, { passive: true });
onScroll();

// ── Mobile menu (hamburger) ──
const navEl = document.getElementById('nav');
const navToggle = document.getElementById('navToggle');
const navScrim = document.getElementById('navScrim');
const navMenu = document.getElementById('navMenu');
if (navToggle && navEl) {
  const setMenu = (open) => {
    navEl.classList.toggle('open', open);
    navToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    navToggle.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    if (navScrim) navScrim.hidden = !open;
    document.body.style.overflow = open ? 'hidden' : '';
  };
  navToggle.addEventListener('click', () => setMenu(!navEl.classList.contains('open')));
  const navClose = document.getElementById('navClose');
  if (navClose) navClose.addEventListener('click', () => setMenu(false));
  if (navScrim) navScrim.addEventListener('click', () => setMenu(false));
  // Close after tapping any in-menu link.
  if (navMenu) navMenu.querySelectorAll('a').forEach((a) => a.addEventListener('click', () => setMenu(false)));
  // Esc closes; leaving mobile width resets state.
  document.addEventListener('keydown', (e) => { if (e.key === 'Escape') setMenu(false); });
  window.matchMedia('(min-width: 901px)').addEventListener('change', (e) => { if (e.matches) setMenu(false); });
}
