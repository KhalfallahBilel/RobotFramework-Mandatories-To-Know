*** Settings ***
Documentation     ==============================================================================
...               FICHIER CENTRAL DES VARIABLES (variables.robot)
...               ==============================================================================
...               Ce fichier regroupe toutes les variables réutilisables partagées entre
...               toutes les suites de tests du projet :
...                 - Configuration globale (URL du serveur, navigateur, timeouts)
...                 - Identifiants de connexion par défaut (Admin, Utilisateurs)
...                 - Chemins des différentes pages web et endpoints API
...
...               💡 BONNE PRATIQUE ROBOT FRAMEWORK :
...               Centraliser les variables ici évite de coder en dur ("hardcoder") des URL
...               ou des identifiants dans les tests. Si l'URL du serveur change (ex: passage
...               de port 5001 à un environnement de recette), il suffit de modifier cette page !
...
...               💡 SURCHARGE EN LIGNE DE COMMANDE :
...               Vous pouvez remplacer n'importe quelle variable à la volée avec l'option --variable :
...               robot --variable BROWSER:firefox --variable BASE_URL:http://127.0.0.1:5001 tests/
...               ==============================================================================

*** Variables ***
# ─────────────────────────────────────────────────────────────────────────────
# 1. APPLICATION & NAVIGATEUR
# ─────────────────────────────────────────────────────────────────────────────
# URL de base de l'application web locale Flask (port 5001)
${BASE_URL}             http://localhost:5001

# Navigateur utilisé par Selenium (chrome, firefox, safari, headlesschrome)
# Note : Pour lancer sans afficher la fenêtre, utilisez 'headlesschrome'
${BROWSER}              chrome

# Indicateur d'exécution sans interface graphique
${HEADLESS}             False

# ─────────────────────────────────────────────────────────────────────────────
# 2. TIMEOUTS ET ATTENTES (SELENIUM)
# ─────────────────────────────────────────────────────────────────────────────
# Timeout par défaut pour les attentes explicites (Wait Until Element Is Visible)
${DEFAULT_TIMEOUT}      10s

# Timeout allongé pour les requêtes plus lentes ou opérations asynchrones
${LONG_TIMEOUT}         20s

# Timeout court pour des vérifications rapides d'éléments déjà présents
${SHORT_TIMEOUT}        3s

# ─────────────────────────────────────────────────────────────────────────────
# 3. IDENTIFIANTS DE TEST PRÉ-CONFIGURÉS
# ─────────────────────────────────────────────────────────────────────────────
# Compte Administrateur (accès à l'ajout, modification et suppression de produits)
${ADMIN_USER}           admin
${ADMIN_PASS}           Admin123!

# Compte Utilisateur Standard 1 (lecture seule, profil utilisateur)
${USER1_USER}           user1
${USER1_PASS}           User123!

# Compte Utilisateur Standard 2 (autre utilisateur pour tester les sessions)
${USER2_USER}           user2
${USER2_PASS}           User123!

# Compte Utilisateur Invalide (pour tester les erreurs de login)
${INVALID_USER}        invaliduser
${INVALID_PASS}        wrongpassword

# ─────────────────────────────────────────────────────────────────────────────
# 4. URLS DES PAGES WEB DE L'APPLICATION
# ─────────────────────────────────────────────────────────────────────────────
${LOGIN_URL}            ${BASE_URL}/login
${REGISTER_URL}         ${BASE_URL}/register
${DASHBOARD_URL}        ${BASE_URL}/dashboard
${PRODUCTS_URL}         ${BASE_URL}/products
${CONTACT_URL}          ${BASE_URL}/contact
${TABLE_URL}            ${BASE_URL}/table
${ALERTS_URL}           ${BASE_URL}/alerts
${DYNAMIC_URL}          ${BASE_URL}/dynamic
${ABOUT_URL}            ${BASE_URL}/about

# ─────────────────────────────────────────────────────────────────────────────
# 5. ENDPOINTS DE L'API REST
# ─────────────────────────────────────────────────────────────────────────────
${API_BASE_URL}         ${BASE_URL}/api
${API_STATUS_URL}       ${BASE_URL}/api/status
${API_PRODUCTS_URL}     ${BASE_URL}/api/products
${API_CONTACTS_URL}     ${BASE_URL}/api/contacts
${API_USERS_URL}        ${BASE_URL}/api/users
