/**
 * ==============================================================================
 * LOGIQUE JAVASCRIPT FRONT-END (webapp/static/js/app.js)
 * ==============================================================================
 * Ce script gère tous les composants interactifs et dynamiques de l'application.
 * Il est spécialement conçu pour fournir des scénarios réalistes à automatiser
 * avec Robot Framework et SeleniumLibrary :
 *   1. Menu mobile réactif (Toggle).
 *   2. Messages flash avec disparition automatique (Auto-dismiss / timing).
 *   3. Système d'onglets (Tabs switcher).
 *   4. Accordéons avec ouverture/fermeture exclusive.
 *   5. Fenêtres modales (Popups, overlay backdrop, fermeture escape/clic).
 *   6. Tri dynamique des colonnes de tableau (Table sort).
 *   7. Boîte de confirmation native confirm() (Alert handling).
 *   8. Délais asynchrones et simulateur de chargement (Spinners / Waits).
 *   9. Filtrage en temps réel à la frappe (Live search).
 *  10. Appel asynchrone à l'API REST (Fetch API).
 * ==============================================================================
 */

// ─────────────────────────────────────────────────────────────────────────────
// 1. MENU RESPONSIVE (TOGGLE MOBILE)
// ─────────────────────────────────────────────────────────────────────────────
const navToggle = document.getElementById('nav-toggle');
const navLinks = document.getElementById('nav-links');
if (navToggle && navLinks) {
  navToggle.addEventListener('click', () => {
    // Bascule la classe CSS 'open' pour afficher ou cacher le menu sur petits écrans
    navLinks.classList.toggle('open');
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. DISPARITION AUTOMATIQUE DES MESSAGES FLASH (TIMING & ANIMATION)
// ─────────────────────────────────────────────────────────────────────────────
// Les alertes s'estompent après 4 secondes pour tester la gestion du timing en automatisation
document.querySelectorAll('.alert').forEach(alert => {
  setTimeout(() => {
    alert.style.transition = 'opacity 0.5s ease';
    alert.style.opacity = '0';
    setTimeout(() => alert.remove(), 500);
  }, 4000);
});

// ─────────────────────────────────────────────────────────────────────────────
// 3. GESTION DES ONGLETS (TABS)
// ─────────────────────────────────────────────────────────────────────────────
// Permet de tester le clic sur des boutons et la vérification de visibilité de panneaux
document.querySelectorAll('.tab-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const container = btn.closest('[data-tabs]') || document;
    const target = btn.dataset.tab;

    // Désactive tous les boutons et panneaux d'onglets du conteneur
    container.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    container.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));

    // Active l'onglet cliqué et son contenu correspondant
    btn.classList.add('active');
    const panel = document.getElementById(target);
    if (panel) panel.classList.add('active');
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 4. ACCORDÉONS (ACCORDIONS / FAQ DÉPLIANTE)
// ─────────────────────────────────────────────────────────────────────────────
// Permet de tester le déploiement/repli et les assertions sur la hauteur ou la visibilité
document.querySelectorAll('.accordion-header').forEach(header => {
  header.addEventListener('click', () => {
    const item = header.closest('.accordion-item');
    const body = item.querySelector('.accordion-body');
    const isOpen = item.classList.contains('open');

    // Ferme tous les autres éléments de l'accordéon (accordéon exclusif)
    document.querySelectorAll('.accordion-item').forEach(i => {
      i.classList.remove('open');
      const b = i.querySelector('.accordion-body');
      if (b) b.style.maxHeight = '0';
    });

    // Si l'élément cliqué était fermé, on l'ouvre
    if (!isOpen) {
      item.classList.add('open');
      body.style.maxHeight = body.scrollHeight + 'px';
    }
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 5. FENÊTRES MODALES (MODALS & POPUPS)
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Ouvre une modale en lui ajoutant la classe CSS 'open'.
 * @param {string} id - L'identifiant du conteneur de la modale.
 */
function openModal(id) {
  const modal = document.getElementById(id);
  if (modal) modal.classList.add('open');
}

// Fermeture de la modale lors d'un clic sur l'arrière-plan semi-transparent (backdrop overlay)
document.querySelectorAll('.modal-overlay').forEach(overlay => {
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) overlay.classList.remove('open');
  });
});

// Boutons déclencheurs portant l'attribut data-modal="id_de_la_modale"
document.querySelectorAll('[data-modal]').forEach(btn => {
  btn.addEventListener('click', () => openModal(btn.dataset.modal));
});

// Boutons de fermeture (croix ou bouton Annuler) portant la classe .modal-close
document.querySelectorAll('.modal-close').forEach(btn => {
  btn.addEventListener('click', () => {
    btn.closest('.modal-overlay').classList.remove('open');
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 6. TRI DYNAMIQUE DE TABLEAU HTML (TABLE SORTING)
// ─────────────────────────────────────────────────────────────────────────────
// Permet de tester le tri des colonnes par ordre alphabétique ou numérique dans Robot Framework
document.querySelectorAll('table th[data-sort]').forEach(th => {
  th.style.cursor = 'pointer';
  th.addEventListener('click', () => {
    const table = th.closest('table');
    const tbody = table.querySelector('tbody');
    const col = Array.from(th.parentElement.children).indexOf(th);
    const asc = th.dataset.dir !== 'asc';
    th.dataset.dir = asc ? 'asc' : 'desc';

    const rows = Array.from(tbody.querySelectorAll('tr'));
    rows.sort((a, b) => {
      const av = a.cells[col]?.textContent.trim() || '';
      const bv = b.cells[col]?.textContent.trim() || '';
      const n = (v) => parseFloat(v.replace(/[^0-9.-]/g, ''));
      // Tri numérique si ce sont des nombres (ex: prix, stock), sinon tri textuel
      if (!isNaN(n(av)) && !isNaN(n(bv))) return asc ? n(av) - n(bv) : n(bv) - n(av);
      return asc ? av.localeCompare(bv) : bv.localeCompare(av);
    });

    // Réinjecte les lignes triées dans le DOM
    rows.forEach(r => tbody.appendChild(r));

    // Met à jour les petites flèches d'indication de direction dans les en-têtes
    table.querySelectorAll('th').forEach(h => h.textContent = h.textContent.replace(/ [▲▼]$/, ''));
    th.textContent += asc ? ' ▲' : ' ▼';
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 7. CONFIRMATION NATIVE JAVASCRIPT (DATA-CONFIRM)
// ─────────────────────────────────────────────────────────────────────────────
// Déclenche window.confirm(), interceptable par le keyword Robot Framework 'Handle Alert'
document.querySelectorAll('[data-confirm]').forEach(el => {
  el.addEventListener('click', (e) => {
    if (!confirm(el.dataset.confirm || 'Are you sure?')) {
      e.preventDefault();
    }
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 8. FONCTIONS UTILITAIRES POUR PAGES DYNAMIQUES & ASYNCHRONES
// ─────────────────────────────────────────────────────────────────────────────
/**
 * Démarre un compte à rebours visuel (test d'attente d'état final).
 */
function startCountdown(id, seconds) {
  let remaining = seconds;
  const el = document.getElementById(id);
  if (!el) return;
  el.textContent = remaining;
  const interval = setInterval(() => {
    remaining--;
    el.textContent = remaining;
    if (remaining <= 0) clearInterval(interval);
  }, 1000);
}

/**
 * Simule le chargement différé d'une liste via spinner d'attente.
 */
function simulateLoadingList(containerId, items, delay = 1500) {
  const container = document.getElementById(containerId);
  if (!container) return;
  container.innerHTML = '<div class="spinner" style="margin:2rem auto;display:block"></div>';
  setTimeout(() => {
    container.innerHTML = items.map(item =>
      `<div class="card" style="margin-bottom:0.75rem"><strong>${item.name}</strong><p class="card-body">${item.desc}</p></div>`
    ).join('');
  }, delay);
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. RECHERCHE EN DIRECT DANS LE TABLEAU (LIVE FILTER)
// ─────────────────────────────────────────────────────────────────────────────
// Filtre instantanément les lignes <tr> du tableau lors de la frappe dans #live-search
const liveSearch = document.getElementById('live-search');
if (liveSearch) {
  liveSearch.addEventListener('input', () => {
    const term = liveSearch.value.toLowerCase();
    document.querySelectorAll('tbody tr').forEach(row => {
      row.style.display = row.textContent.toLowerCase().includes(term) ? '' : 'none';
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. APPEL REST API (FETCH)
// ─────────────────────────────────────────────────────────────────────────────
// Récupère les données de statut de l'API en direct et les affiche dans un conteneur
async function fetchApiStatus() {
  try {
    const res = await fetch('/api/status');
    const data = await res.json();
    const el = document.getElementById('api-status-result');
    if (el) el.textContent = JSON.stringify(data, null, 2);
  } catch (e) {
    console.error('Erreur API :', e);
  }
}

// Animation automatique des barres de progression au chargement de la page
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.progress-bar[data-value]').forEach(bar => {
    setTimeout(() => {
      bar.style.width = bar.dataset.value + '%';
    }, 100);
  });
});
