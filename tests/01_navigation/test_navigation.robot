*** Settings ***
Documentation     ==============================================================================
...               SUITE 01 — TESTS DE NAVIGATION ET DE CHARGEMENT DE PAGES
...               ==============================================================================
...               Cette suite teste :
...                 1. L'accès à la page d'accueil et le bon rendu des éléments clés.
...                 2. Les liens de la barre de navigation (Header).
...                 3. La navigation vers chacune des sous-pages (Products, Contact, About, etc.).
...                 4. Le fonctionnement des liens dans les sections Hero, Cards et Footer.
...                 5. La navigation avec fil d'Ariane (Breadcrumb) et historique navigateur (Go Back).
...
...               💡 CONCEPTS ROBOT FRAMEWORK ABORDÉS :
...                 - Suite Setup / Teardown : initialise le navigateur au début de la suite et le ferme à la fin.
...                 - Test Setup : réinitialise l'état avant chaque test (retour à l'accueil).
...                 - Tags ([Tags]) : catégorise les tests (ex: 'smoke', 'navigation') pour les filtrer.
...                 - Sélecteurs Selenium : ciblage par identifiant unique (id:xxx) ou chemin XPath (xpath:xxx).
...               ==============================================================================

# Bibliothèques et ressources externes requises
Library           SeleniumLibrary
Resource          ../variables.robot
Resource          ../keywords.robot

# Initialisation : ouvre le navigateur une seule fois pour toute la suite (gain de rapidité)
Suite Setup       Open Browser And Go To Home

# Nettoyage : ferme le navigateur une fois tous les tests de la suite terminés
Suite Teardown    Close Browser And Cleanup

# Avant chaque test individuel : revient à la page d'accueil pour repartir d'un état propre
Test Setup        Go To    ${BASE_URL}

*** Test Cases ***

# ── TC01: PAGE D'ACCUEIL ──────────────────────────────────────────────────────
TC01 - Verify Home Page Loads
    [Documentation]    Vérifie que la page d'accueil se charge avec succès :
    ...                - Le titre de la page correspond exactement à l'attendu.
    ...                - Le logo / marque de la barre de navigation est visible.
    ...                - Les boutons d'appel à l'action (Hero section) sont présents.
    ...                - Le contenu textuel principal est présent dans la page.
    [Tags]             smoke    navigation
    # Vérification du titre de l'onglet du navigateur
    Title Should Be              Home — Robot Framework Training
    # Vérification de la visibilité des éléments HTML via leur ID unique
    Element Should Be Visible    id:nav-brand
    Element Should Be Visible    id:hero-btn-products
    Element Should Be Visible    id:hero-btn-login
    # Vérification que le texte clé existe dans le DOM
    Page Should Contain          RobotApp
    Page Should Contain          Robot Framework Training

# ── TC02: LIENS DE LA BARRE DE NAVIGATION ────────────────────────────────────
TC02 - Verify Navigation Links Are Present
    [Documentation]    S'assure que tous les liens du menu principal sont affichés à l'écran.
    ...                Permet de détecter immédiatement un menu cassé ou une régression CSS.
    [Tags]             smoke    navigation
    Element Should Be Visible    id:nav-home
    Element Should Be Visible    id:nav-products
    Element Should Be Visible    id:nav-table
    Element Should Be Visible    id:nav-alerts
    Element Should Be Visible    id:nav-dynamic
    Element Should Be Visible    id:nav-contact
    Element Should Be Visible    id:nav-about

# ── TC03: NAVIGATION VERS LA PAGE PRODUITS ───────────────────────────────────
TC03 - Navigate To Products Page
    [Documentation]    Clique sur le lien 'Products' de la barre de navigation :
    ...                - Attend que le mot 'Products' s'affiche sur la nouvelle page.
    ...                - Vérifie que l'URL courante contient bien '/products'.
    [Tags]             navigation
    Click Link                   id:nav-products
    Wait Until Page Contains     Products    timeout=${DEFAULT_TIMEOUT}
    # Récupération de l'URL actuelle dans une variable locale ${url}
    ${url}=                      Get Location
    Should Contain               ${url}    /products

# ── TC04: NAVIGATION VERS LA PAGE CONTACT ────────────────────────────────────
TC04 - Navigate To Contact Page
    [Documentation]    Clique sur 'Contact' et valide la présence du formulaire de message.
    [Tags]             navigation
    Click Link                   id:nav-contact
    Wait Until Page Contains     Contact Us    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    id:contact-form

# ── TC05: NAVIGATION VERS LA PAGE À PROPOS ───────────────────────────────────
TC05 - Navigate To About Page
    [Documentation]    Clique sur 'About' et s'assure que la grille de présentation de l'équipe est visible.
    [Tags]             navigation
    Click Link                   id:nav-about
    Wait Until Page Contains     About RobotApp    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    id:team-grid

# ── TC06: NAVIGATION VERS LA PAGE TABLEAU DE DONNÉES ─────────────────────────
TC06 - Navigate To Table Page
    [Documentation]    Clique sur 'Table' et s'assure que le tableau HTML de données est bien rendu.
    [Tags]             navigation
    Click Link                   id:nav-table
    Wait Until Page Contains     Data Table    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    id:products-table

# ── TC07: NAVIGATION VERS LA PAGE ALERTES & COMPOSANTS ───────────────────────
TC07 - Navigate To Alerts Page
    [Documentation]    Vérifie l'accès à la page des composants interactifs (modals, tabs, alertes).
    [Tags]             navigation
    Click Link                   id:nav-alerts
    Wait Until Page Contains     UI Components    timeout=${DEFAULT_TIMEOUT}

# ── TC08: NAVIGATION VERS LA PAGE CONTENU DYNAMIQUE ─────────────────────────
TC08 - Navigate To Dynamic Page
    [Documentation]    Vérifie l'accès à la page de tests des temps d'attente et chargements asynchrones.
    [Tags]             navigation
    Click Link                   id:nav-dynamic
    Wait Until Page Contains     Dynamic Content    timeout=${DEFAULT_TIMEOUT}

# ── TC09: CARTES CLICABLES DU HERO ET HISTORIQUE NAVIGATEUR ──────────────────
TC09 - Hero Section Cards Link To Pages
    [Documentation]    Teste les cartes de raccourci sur la page d'accueil :
    ...                - Clic sur la carte 'Products' -> vérification de la page.
    ...                - Clic sur la carte 'Contact' -> vérification de la page.
    [Tags]             navigation
    Scroll Element Into View     id:home-card-products
    Click Element                id:home-card-products
    Wait Until Page Contains     Products    timeout=${DEFAULT_TIMEOUT}
    Go Back
    Wait Until Page Contains     Robot Framework Training    timeout=${DEFAULT_TIMEOUT}
    Scroll Element Into View     id:home-card-contact
    Click Element                id:home-card-contact
    Wait Until Page Contains     Contact Us    timeout=${DEFAULT_TIMEOUT}
    # Simulation du clic sur le bouton retour du navigateur

# ── TC10: TABLEAU DES ENDPOINTS API SUR LA PAGE D'ACCUEIL ────────────────────
TC10 - API Table Is Displayed On Home Page
    [Documentation]    Vérifie que la documentation des endpoints REST est visible sur la page d'accueil.
    [Tags]             navigation
    Element Should Be Visible    id:api-endpoints-table
    Page Should Contain          /api/status
    Page Should Contain          /api/products

# ── TC11: LIENS DU PIED DE PAGE (FOOTER) ─────────────────────────────────────
TC11 - Footer Links Are Present
    [Documentation]    S'assure que le conteneur du footer et ses liens techniques sont visibles.
    [Tags]             navigation
    Element Should Be Visible    id:footer
    Element Should Be Visible    id:footer-api-status
    Element Should Be Visible    id:footer-api-products

# ── TC12: LIEN DE CONNEXION DEPUIS LA BARRE DE NAVIGATION ────────────────────
TC12 - Login Link Navigates To Login Page
    [Documentation]    Clique sur le bouton 'Login' dans le menu et valide la redirection vers /login.
    [Tags]             navigation
    Click Link                   id:nav-login
    Wait Until Element Is Visible    id:login-form
    ${url}=                      Get Location
    Should Contain               ${url}    /login

# ── TC13: NAVIGATION VIA FIL D'ARIANE (BREADCRUMB) ───────────────────────────
TC13 - Breadcrumb Navigation On Product Detail
    [Documentation]    Navigue directement vers la fiche détaillée du produit 1, puis utilise
    ...                le fil d'Ariane (breadcrumb) pour revenir vers la liste des produits.
    ...                Montre l'utilisation d'un sélecteur XPath relatif pour cibler un lien précis.
    [Tags]             navigation
    Go To                        ${PRODUCTS_URL}/1
    Wait Until Element Is Visible    id:breadcrumb-product-name
    # Clic sur le lien 'Products' contenu dans le conteneur de classe 'breadcrumb'
    Click Link                   xpath://div[@class='breadcrumb']//a[contains(text(), 'Products')]
    Wait Until Page Contains     Products
