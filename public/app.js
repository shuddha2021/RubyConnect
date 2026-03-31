/* ── Theme Toggle ────────────────────────────────────────── */
const html = document.documentElement;
let dark = localStorage.getItem('rc-theme') === 'dark' ||
  (!localStorage.getItem('rc-theme') && window.matchMedia('(prefers-color-scheme:dark)').matches);
applyTheme();

document.getElementById('themeBtn').addEventListener('click', () => {
  dark = !dark;
  applyTheme();
  localStorage.setItem('rc-theme', dark ? 'dark' : 'light');
});

function applyTheme() {
  html.setAttribute('data-theme', dark ? 'dark' : 'light');
}

/* ── Contact Modal ──────────────────────────────────────── */
const backdrop = document.getElementById('contactBackdrop');
const modal    = document.getElementById('contactModal');

function openContact() {
  backdrop.classList.add('active');
  modal.classList.add('active');
  const first = modal.querySelector('input');
  if (first) first.focus();
}

function closeContact() {
  backdrop.classList.remove('active');
  modal.classList.remove('active');
}

const contactBtn = document.getElementById('contactBtn');
if (contactBtn) contactBtn.addEventListener('click', openContact);
document.getElementById('contactClose').addEventListener('click', closeContact);
document.getElementById('contactCancel').addEventListener('click', closeContact);
backdrop.addEventListener('click', closeContact);

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && modal.classList.contains('active')) closeContact();
});

/* ── Auto-dismiss alerts ────────────────────────────────── */
document.querySelectorAll('.alert').forEach(el => {
  setTimeout(() => {
    el.style.transition = 'opacity .3s';
    el.style.opacity = '0';
    setTimeout(() => el.remove(), 300);
  }, 4000);
});
