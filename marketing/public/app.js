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

// ── Reveal on scroll (fade-in + staggered children) ──
const io = new IntersectionObserver(
  (entries) => entries.forEach((e) => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } }),
  { threshold: 0.12 }
);
document.querySelectorAll('.reveal').forEach((el) => io.observe(el));

// Staggered groups: index each child so CSS can cascade the delay.
document.querySelectorAll('.reveal-stagger').forEach((group) => {
  Array.from(group.children).forEach((child, i) => child.style.setProperty('--i', i));
  io.observe(group);
});

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
const flipEl = document.querySelector('.phone-showcase');
const rmShowcase = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
if (shots.length && steps.length) {
  let currentStep = '0';
  const swapShots = (n) => shots.forEach((s) => s.classList.toggle('is-active', s.dataset.step === n));
  function setStep(nRaw) {
    const n = String(nRaw);
    if (n === currentStep) return;
    currentStep = n;
    // Text panel updates immediately…
    steps.forEach((s) => s.classList.toggle('is-active', s.dataset.step === n));
    // …the phone does a quick 3D flip and swaps the screen at the edge.
    if (flipEl && !rmShowcase) {
      // Turn the whole phone to its edge (3D), swap the screen, turn back.
      flipEl.classList.add('flipping');
      setTimeout(() => { swapShots(n); flipEl.classList.remove('flipping'); }, 330);
    } else {
      swapShots(n);
    }
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
// (The hero phone is driven by the GSAP timeline; the showcase phone's transform
// is owned by the flip, so we don't tilt it here anymore.)
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
// Generic parallax layers (section background glows). Each drifts relative to
// its own distance from the viewport centre, so the effect runs the whole page.
const parallaxEls = Array.from(document.querySelectorAll('[data-parallax]'));
// Global background layers — drift at different rates the whole page long → depth.
const siteBgLayers = [
  ['.site-bg-glow', 0.12],
  ['.site-bg-dots', 0.05],
  ['.site-bg-near', 0.20],
].map(([sel, f]) => [document.querySelector(sel), f]).filter(([el]) => el);

let ticking = false;
function onScroll() {
  if (ticking) return;
  ticking = true;
  requestAnimationFrame(() => {
    const y = window.scrollY || window.pageYOffset;
    const vh = window.innerHeight;
    const docH = document.documentElement.scrollHeight - window.innerHeight;
    if (progress) progress.style.transform = `scaleX(${docH > 0 ? y / docH : 0})`;
    if (nav) nav.classList.toggle('scrolled', y > 8);
    if (!reduceMotion) {
      // Whole-site parallax: each bg layer drifts at its own rate.
      for (const [el, f] of siteBgLayers) el.style.transform = `translateY(${(y * f).toFixed(1)}px)`;
      for (const el of parallaxEls) {
        const r = el.getBoundingClientRect();
        const offset = (r.top + r.height / 2) - vh / 2;
        const speed = parseFloat(el.dataset.speed || '0.1');
        // Layers are horizontally centred, so keep the -50% X and drift on Y.
        el.style.transform = `translateX(-50%) translateY(${(-offset * speed).toFixed(1)}px)`;
      }
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
  window.matchMedia('(min-width: 1025px)').addEventListener('change', (e) => { if (e.matches) setMenu(false); });
}

// ── Analytics ──────────────────────────────────────────────────────────────
// Provider-agnostic. Fires to whichever tag is loaded (Plausible or GA4); a
// no-op until you enable one in index.html's <head>. Set
// window.__cmAnalyticsDebug = true in the console to log events locally.
function track(name, props) {
  try { if (typeof window.plausible === 'function') window.plausible(name, props ? { props } : undefined); } catch (e) { /* ignore */ }
  try { if (typeof window.gtag === 'function') window.gtag('event', name, props || {}); } catch (e) { /* ignore */ }
  if (window.__cmAnalyticsDebug) console.log('[track]', name, props || {});
}
window.cmTrack = track; // exposed for ad-hoc/manual events

// CTA clicks — delegated, so it covers every [data-cta] now and in future.
document.addEventListener('click', (e) => {
  const el = e.target.closest('[data-cta]');
  if (!el) return;
  track('cta_click', { id: el.dataset.cta, location: el.dataset.ctaLoc || 'unknown' });
});

// Video engagement — play, quartile depth, completion, pause, seek.
const demoVideo = document.querySelector('.demo-video');
if (demoVideo) {
  const fired = new Set();
  const once = (key, name, props) => { if (!fired.has(key)) { fired.add(key); track(name, props); } };

  demoVideo.addEventListener('play', () => once('play', 'play_demo'));
  demoVideo.addEventListener('ended', () => track('demo_complete'));
  // Pause that isn't the natural end-of-video.
  demoVideo.addEventListener('pause', () => {
    if (demoVideo.currentTime < (demoVideo.duration || Infinity) - 0.3) {
      track('demo_pause', { at_pct: pct() });
    }
  });
  // Manual seek (user dragged the scrubber).
  demoVideo.addEventListener('seeked', () => track('demo_seek', { to_pct: pct() }));
  // Quartile milestones, each fired once.
  demoVideo.addEventListener('timeupdate', () => {
    const p = pct();
    if (p >= 25) once('25', 'demo_25');
    if (p >= 50) once('50', 'demo_50');
    if (p >= 75) once('75', 'demo_75');
  });

  function pct() {
    const d = demoVideo.duration;
    return d ? Math.round((demoVideo.currentTime / d) * 100) : 0;
  }
}

// ── Hero scroll animation (GSAP ScrollTrigger) ──────────────────────────────
// Pinned cinematic stage: phone flies in from the left → centres → straightens
// → 3D Y-flip to the schedule → settles to the right as the copy reveals, over
// 3 parallax layers. Desktop does the 3D; mobile slides in + parallax only.
if (window.gsap && document.querySelector('.hero-stage')) {
  if (window.ScrollTrigger) gsap.registerPlugin(ScrollTrigger);
  const mm = gsap.matchMedia();
  // Hero entrance — copy + phone are visible by default; this just eases them in
  // on load (no scroll-gating, so the welcome text is never hidden).
  mm.add('(prefers-reduced-motion: no-preference)', () => {
    gsap.from('.hero-stage .hero-copy > *', { opacity: 0, y: 26, stagger: 0.08, duration: 0.7, ease: 'power3.out', delay: 0.08 });
    gsap.from('.hero-phone-pos', { opacity: 0, y: 36, scale: 0.9, duration: 0.95, ease: 'power3.out', delay: 0.14 });
    return () => {};
  });

  // ── Showcase: sticky 3D phone that spins continuously (one smooth sail, never
  // freezing) and dribbles side to side between the texts; screens swap while
  // the phone is edge-on/back-facing (unseen).
  if (window.ScrollTrigger) mm.add('(min-width: 769px) and (prefers-reduced-motion: no-preference)', () => {
    const wrap = document.querySelector('.sc-wrap');
    const box = document.querySelector('.sc-phone-3d');
    const front = document.querySelector('.sc-shot-f');
    const back = document.querySelector('.sc-shot-b');
    const copies = Array.from(document.querySelectorAll('.sc-copy'));
    if (!wrap || !box || !front || !back || !copies.length) return;

    const SRC = ['nova', 'schedule', 'classroom', 'solutions', 'grades', 'practice']
      .map((n) => `assets/shot-${n}-light.png`);
    const N = SRC.length, seg = N - 1;
    const ampX = () => Math.min(window.innerWidth * 0.20, 360);

    // front face = even screens, back = odd → the right screen is upright at each
    // multiple of 180°. Only the hidden face is ever swapped.
    const setFaces = (from) => {
      const a = Math.max(0, Math.min(N - 1, from));
      const b = Math.max(0, Math.min(N - 1, from + 1));
      const evenS = a % 2 === 0 ? a : b;
      const oddS = a % 2 === 0 ? b : a;
      if (front.dataset.s != evenS) { front.src = SRC[evenS]; front.dataset.s = evenS; }
      if (back.dataset.s != oddS) { back.src = SRC[oddS]; back.dataset.s = oddS; }
    };
    setFaces(0);
    copies.forEach((c, i) => c.classList.toggle('is-active', i === 0));

    ScrollTrigger.create({
      trigger: wrap, start: 'top top', end: 'bottom bottom', scrub: 0.7, invalidateOnRefresh: true,
      onUpdate: (self) => {
        const p = self.progress;
        const rotY = p * seg * 180;                          // continuous spin
        const x = -ampX() * Math.cos(p * seg * Math.PI);     // zig-zag dribble
        const tiltX = Math.sin(p * seg * Math.PI * 2) * 5;   // subtle tumble
        gsap.set(box, { rotationY: rotY, x, rotationX: tiltX });
        setFaces(Math.floor(p * seg + 1e-4));
        const cur = Math.round(p * seg);
        copies.forEach((c, i) => c.classList.toggle('is-active', i === cur));
      },
    });
    return () => { gsap.set(box, { clearProps: 'all' }); };
  });

  if (window.ScrollTrigger) {
    let rt; window.addEventListener('resize', () => { clearTimeout(rt); rt = setTimeout(() => ScrollTrigger.refresh(), 200); });
  }
}
