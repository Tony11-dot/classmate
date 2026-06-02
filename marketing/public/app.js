// Year
document.getElementById('year').textContent = new Date().getFullYear();

// Theme toggle (respects saved choice, then system)
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

// Scroll reveal
const io = new IntersectionObserver(
  (entries) => entries.forEach((e) => { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } }),
  { threshold: 0.12 }
);
document.querySelectorAll('.reveal').forEach((el) => io.observe(el));

// Role tabs
const tabs = document.querySelectorAll('.role-tab');
const panels = document.querySelectorAll('.role-panel');
tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    const role = tab.dataset.role;
    tabs.forEach((t) => t.classList.toggle('active', t === tab));
    panels.forEach((p) => p.classList.toggle('active', p.dataset.role === role));
  });
});

// When real screenshots are dropped in /assets, swap any placeholder whose
// matching <shot>-light.png exists. Filenames follow data-shot + "-light.png".
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
