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
if (window.gsap && window.ScrollTrigger && document.querySelector('.hero-stage')) {
  gsap.registerPlugin(ScrollTrigger);
  const copyEls = '.hero-stage .hero-copy > *';
  const mm = gsap.matchMedia();

  // Desktop — full 3D pinned timeline.
  mm.add('(min-width: 769px) and (prefers-reduced-motion: no-preference)', () => {
    gsap.set('.hero-phone-pos', { xPercent: -50, yPercent: -50, opacity: 1, transformOrigin: '50% 50%' });
    // transformPerspective puts the flip in true 3D (whole phone turns, near edge
    // forward) instead of a flat "book page" squish.
    gsap.set('.hero-phone-flip', { transformPerspective: 1200, transformOrigin: '50% 50%' });
    gsap.set(copyEls, { opacity: 0, y: 30 });

    const settleX = () => Math.min(window.innerWidth * 0.2, 260);

    const tl = gsap.timeline({
      defaults: { ease: 'power2.inOut' },
      scrollTrigger: {
        trigger: '.hero-stage', start: 'top top', end: 'bottom bottom',
        scrub: 0.6, pin: '.hero-pin', anticipatePin: 1, invalidateOnRefresh: true,
      },
    });

    // 0–25%: fly LEFT → CENTRE, scale 0.8→0.95, straighten rotateZ −15→0.
    tl.fromTo('.hero-phone-pos',
      { x: -600, scale: 0.8, rotationZ: -15 },
      { x: 0, scale: 0.95, rotationZ: 0, duration: 25 }, 0);
    // 25–40%: confident — scale 0.95→1.0 (centred).
    tl.to('.hero-phone-pos', { scale: 1.0, duration: 15 }, 25);
    // 40–65%: 3D flip on Y (fixed size), back face = schedule screenshot.
    tl.to('.hero-phone-flip', { rotationY: 180, duration: 25 }, 40);
    // 65–100%: settle to the right + slight upward drift.
    tl.to('.hero-phone-pos', { x: settleX, y: '-=22', duration: 35 }, 65);
    // Text reveals as the phone settles (stagger 0.1).
    tl.to('.hero-stage .pill', { opacity: 1, y: 0, duration: 10 }, 64)
      .to('.hero-stage h1', { opacity: 1, y: 0, duration: 10 }, 66)
      .to('.hero-stage .lead', { opacity: 1, y: 0, duration: 10 }, 69)
      .to('.hero-stage .hero-actions', { opacity: 1, y: 0, duration: 10 }, 72)
      .to('.hero-stage .hero-badges', { opacity: 1, y: 0, duration: 10 }, 75);

    // 3 parallax layers — translateY at 20% / 50% / 80% of a viewport height as
    // you scroll the pin. Far layer drifts slowly, close layer rushes → depth.
    const vH = () => window.innerHeight;
    tl.fromTo('.hero-bg-1', { y: 0 }, { y: () => -0.20 * vH(), duration: 100, ease: 'none' }, 0);
    tl.fromTo('.hero-bg-2', { y: 0 }, { y: () => -0.50 * vH(), duration: 100, ease: 'none' }, 0);
    tl.fromTo('.hero-bg-3', { y: 0 }, { y: () => -0.80 * vH(), duration: 100, ease: 'none' }, 0);

    return () => { gsap.set('.hero-phone-pos', { clearProps: 'all' }); gsap.set(copyEls, { clearProps: 'all' }); };
  });

  // Mobile — slide-in + parallax, NO 3D, no pin.
  mm.add('(max-width: 768px) and (prefers-reduced-motion: no-preference)', () => {
    gsap.set('.hero-phone-pos', { opacity: 1 });
    gsap.from('.hero-phone-flip', {
      x: -70, opacity: 0, duration: 0.8, ease: 'power2.out',
      scrollTrigger: { trigger: '.hero-stage', start: 'top 80%' },
    });
    gsap.fromTo(copyEls, { opacity: 0, y: 24 }, {
      opacity: 1, y: 0, stagger: 0.1, duration: 0.6, ease: 'power2.out',
      scrollTrigger: { trigger: '.hero-stage', start: 'top 78%' },
    });
    const vHm = () => window.innerHeight;
    [['.hero-bg-1', 0.20], ['.hero-bg-2', 0.50], ['.hero-bg-3', 0.80]].forEach(([sel, f]) => {
      gsap.fromTo(sel, { y: 0 }, { y: () => -f * vHm(), ease: 'none',
        scrollTrigger: { trigger: '.hero-stage', start: 'top top', end: 'bottom top', scrub: true } });
    });
    return () => {};
  });

  // Showcase parallax — depth layers drift behind the sticky phone as you
  // scroll the #screens section (far layer slow, dot layer faster).
  if (document.querySelector('.showcase-bg-1')) {
    const svH = () => window.innerHeight;
    gsap.fromTo('.showcase-bg-1', { y: 0 }, { y: () => -0.30 * svH(), ease: 'none',
      scrollTrigger: { trigger: '#screens', start: 'top bottom', end: 'bottom top', scrub: true } });
    gsap.fromTo('.showcase-bg-2', { y: 0 }, { y: () => -0.70 * svH(), ease: 'none',
      scrollTrigger: { trigger: '#screens', start: 'top bottom', end: 'bottom top', scrub: true } });
  }

  // Debounced resize → recompute pin/positions.
  let rt; window.addEventListener('resize', () => { clearTimeout(rt); rt = setTimeout(() => ScrollTrigger.refresh(), 200); });
}
