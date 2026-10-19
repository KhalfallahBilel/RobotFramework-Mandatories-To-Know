*** Settings ***
Documentation     ==============================================================================
...               BIBLIOTHÈQUE DE MOTS-CLÉS PERSONNALISÉS (keywords.robot)
...               ==============================================================================
...               Ce fichier contient les "Keywords" réutilisables dans tout le projet.
...
...               💡 PRINCIPE DES KEYWORDS :
...               En Robot Framework, un Keyword est l'équivalent d'une fonction ou méthode :
...               il regroupe une séquence d'actions techniques Selenium (cliquer, saisir, attendre)
...               sous un nom métier compréhensible (ex: 'Login As Admin', 'Navigate To Products').
...               Cela rend les cas de tests lisibles comme du texte naturel (approche Keyword-Driven).
...
...               💡 RÈGLE DES ESPACES :
...               En Robot Framework, les arguments d'un mot-clé doivent TOUJOURS être séparés
...               par au moins DEUX ESPACES (ou une tabulation). Un seul espace est considéré
...               comme faisant partie du même mot.
...               ==============================================================================

# Importation de SeleniumLibrary : fournit tous les mots-clés pour piloter le navigateur
Library           SeleniumLibrary

# Importation du fichier de variables partagées
Resource          variables.robot

*** Keywords ***

# ─────────────────────────────────────────────────────────────────────────────
# 1. GESTION DU NAVIGATEUR (SETUP / TEARDOWN)
# ─────────────────────────────────────────────────────────────────────────────

Open Browser And Go To Home
    [Documentation]    Ouvre le navigateur, maximise la fenêtre, configure un délai d'attente
    ...                implicite et vérifie que la page d'accueil s'affiche avec le bon titre.
    ...                Utilisé typiquement en 'Suite Setup'.
    Open Browser                  ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Implicit Wait    ${DEFAULT_TIMEOUT}
    Title Should Be               Home — Robot Framework Training

Open Browser Headless
    [Documentation]    Ouvre Google Chrome en mode invisible ('headless').
    ...                Idéal pour l'intégration continue (CI/CD) ou pour exécuter
    ...                les tests en tâche de fond sans afficher de fenêtre graphique.
    ${options}=                   Evaluate    selenium.webdriver.ChromeOptions()    selenium.webdriver
    Call Method                   ${options}    add_argument    --headless
    Call Method                   ${options}    add_argument    --no-sandbox
    Call Method                   ${options}    add_argument    --disable-dev-shm-usage
    Create Webdriver              Chrome    options=${options}
    Go To                         ${BASE_URL}
    Set Selenium Implicit Wait    ${DEFAULT_TIMEOUT}

Close Browser And Cleanup
    [Documentation]    Ferme toutes les fenêtres du navigateur ouvertes par Selenium.
    ...                Utilisé typiquement en 'Suite Teardown' pour libérer la mémoire.
    Close Browser

# ─────────────────────────────────────────────────────────────────────────────
# 2. AUTHENTIFICATION & SESSIONS UTILISATEUR
# ─────────────────────────────────────────────────────────────────────────────

Login As
    [Documentation]    Procédure complète de connexion avec des identifiants paramétrables.
    ...                Prend 2 arguments obligatoires : ${username} et ${password}.
    ...                Étapes :
    ...                  1. Navigue vers la page de login
    ...                  2. Attend que le formulaire soit visible (évite les erreurs de chargement)
    ...                  3. Saisit le login et le mot de passe
    ...                  4. Clique sur le bouton de connexion
    ...                  5. Attend l'apparition du tableau de bord (preuve que le login a réussi)
    [Arguments]                   ${username}    ${password}
    Go To                         ${LOGIN_URL}
    Wait Until Element Is Visible    id:login-form
    Input Text                    id:username    ${username}
    Input Text                    id:password    ${password}
    Click Button                  id:login-submit-btn
    Wait Until Element Is Visible    id:dashboard-title    timeout=${DEFAULT_TIMEOUT}

Login As Admin
    [Documentation]    Raccourci pour se connecter directement avec le compte administrateur.
    Login As                      ${ADMIN_USER}    ${ADMIN_PASS}

Login As User1
    [Documentation]    Raccourci pour se connecter avec le premier utilisateur standard.
    Login As                      ${USER1_USER}    ${USER1_PASS}

Login As User2
    [Documentation]    Raccourci pour se connecter avec le second utilisateur standard.
    Login As                      ${USER2_USER}    ${USER2_PASS}

Login As Invalid User
    [Documentation]    Tente de se connecter avec des identifiants invalides pour tester
    ...                la gestion des erreurs et l'affichage d'un message flash.
    Login As                      ${INVALID_USER}    ${INVALID_PASS}
    Flash Message Should Be Visible    Invalid username or password        

Logout
    [Documentation]    Déconnecte l'utilisateur courant en cliquant sur le lien de déconnexion,
    ...                puis s'assure du retour sur la page de login.
    Click Link                    id:nav-logout
    Wait Until Element Is Visible    id:nav-login    timeout=${DEFAULT_TIMEOUT}

# ─────────────────────────────────────────────────────────────────────────────
# 3. NAVIGATION DANS LES PAGES PRINCIPALES
# ─────────────────────────────────────────────────────────────────────────────

Navigate To Products
    [Documentation]    Clique sur le lien du menu vers la liste des produits et attend la grille.
    Click Link                    id:nav-products
    Wait Until Element Is Visible    id:products-grid    timeout=${DEFAULT_TIMEOUT}

Navigate To Contact
    [Documentation]    Clique sur le lien du menu vers la page de contact et attend le formulaire.
    Click Link                    id:nav-contact
    Wait Until Element Is Visible    id:contact-form

Navigate To Table
    [Documentation]    Clique sur le menu pour aller à la page Table et attend le tableau de données.
    Click Link                    id:nav-table
    Wait Until Element Is Visible    id:products-table

Navigate To Dashboard
    [Documentation]    Clique sur le menu vers le Dashboard et attend le titre du tableau de bord.
    Click Link                    id:nav-dashboard
    Wait Until Element Is Visible    id:dashboard-title

# ─────────────────────────────────────────────────────────────────────────────
# 4. ASSERTIONS & VÉRIFICATIONS RÉUTILISABLES
# ─────────────────────────────────────────────────────────────────────────────

Page Title Should Contain
    [Documentation]    Vérifie qu'une sous-chaîne est présente dans le titre de la page actuelle.
    [Arguments]                   ${text}
    ${title}=                     Get Title
    Should Contain                ${title}    ${text}

Flash Message Should Be Visible
    [Documentation]    Vérifie qu'un message flash de notification (succès, info, alerte)
    ...                est affiché à l'écran et contient le texte attendu.
    [Arguments]                   ${expected_text}
    Wait Until Element Is Visible    id:flash-container
    Page Should Contain           ${expected_text}

Element Text Should Be
    [Documentation]    Récupère le texte d'un élément repéré par son locator (${locator})
    ...                et vérifie qu'il est exactement égal à la valeur attendue (${expected}).
    [Arguments]                   ${locator}    ${expected}
    ${text}=                      Get Text    ${locator}
    Should Be Equal               ${text}    ${expected}

# ─────────────────────────────────────────────────────────────────────────────
# 5. DIAGNOSTIC ET CAPTURES D'ÉCRAN
# ─────────────────────────────────────────────────────────────────────────────

Take Screenshot On Failure
    [Documentation]    Capture une capture d'écran de l'état actuel du navigateur.
    ...                Très utile configuré dans 'Test Teardown' avec :
    ...                Run Keyword If Test Failed    Take Screenshot On Failure
    Capture Page Screenshot
