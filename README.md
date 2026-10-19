# 🤖 Robot Framework Training — Environnement d'Apprentissage Complet

Bienvenue dans votre environnement d'apprentissage pratique pour **Robot Framework** et l'automatisation de tests web & API.

---

## 🚀 Démarrage Rapide

### 1. Ouvrir le projet dans le terminal
```bash
cd "/Users/bilelkhalfallah/Desktop/Auto tests /RobotFramework-Training"
```

### 2. Lancer tous les tests en 1 commande
```bash
./run_tests.sh
```
*Le script démarre automatiquement le serveur Flask sur `http://localhost:5001`, exécute tous les tests et affiche le lien vers le rapport HTML.*

### 3. Voir le rapport de test
```bash
open reports/report.html
```

---

## 📚 Documentation Complète

Pour découvrir toutes les commandes utiles, options de filtrage, exécution headless, tests individuels et syntaxe détaillée :

👉 **Consultez le guide : [`COMMANDES.md`](COMMANDES.md)**

---

## 📁 Architecture du Projet

```text
RobotFramework-Training/
├── COMMANDES.md          # Guide exhaustif de toutes les commandes et syntaxes
├── README.md             # Présentation rapide du projet
├── requirements.txt      # Dépendances Python installées dans le venv
├── run_tests.sh          # Script d'exécution unifié (démarrage + tests + rapport)
├── start_server.py       # Lanceur du serveur Flask avec vérification de santé
├── venv/                 # Environnement virtuel Python autonome
├── reports/              # Rapports générés (report.html, log.html, captures)
├── webapp/               # Application web d'entraînement (Flask, HTML, CSS, JS)
│   ├── app.py            # Serveur Flask et API REST
│   ├── templates/        # Vues HTML (index, login, products, contact, etc.)
│   └── static/           # Feuilles de style et scripts JavaScript
└── tests/                # Suites de tests Robot Framework
    ├── variables.robot   # Configuration globale et variables partagées
    ├── keywords.robot    # Bibliothèque de mots-clés réutilisables
    ├── 01_navigation/    # Suite 01 : Tests de navigation et menus
    ├── 02_forms/         # Suite 02 : Formulaires, authentification & inscription
    ├── 03_crud/          # Suite 03 : Cycle CRUD produits & contrôle d'accès
    ├── 04_api/           # Suite 04 : Tests d'API REST sans navigateur
    └── 05_advanced/      # Suite 05 : Modales, onglets, accordéons, délais AJAX
```
