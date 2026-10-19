*** Settings ***
Documentation     ==============================================================================
...               SUITE 02 — FORMULAIRES, AUTHENTIFICATION ET VALIDATIONS
...               ==============================================================================
...               Cette suite teste en profondeur :
...                 1. La connexion (Login) :
...                    - Connexion réussie pour l'administrateur et l'utilisateur standard.
...                    - Rejet et messages d'erreur clairs en cas de mauvais identifiants ou champs vides.
...                 2. La déconnexion (Logout) et l'invalidation de session.
...                 3. L'inscription (Register) :
...                    - Contrôle de la correspondance des mots de passe.
...                    - Détection des doublons d'utilisateurs.
...                    - Validation du format de l'adresse e-mail.
...                    - Création effective d'un nouvel utilisateur avec nom unique calculé.
...                 4. Le formulaire de contact (Contact Form) :
...                    - Saisie de texte, sélection de liste déroulante (Select By Value).
...                    - Boutons radio (Rating de satisfaction 1 à 5 avec boucle FOR).
...                    - Cases à cocher (Newsletter avec sélection/désélection).
...
...               💡 BONNES PRATIQUES D'AUTOMATISATION DE FORMULAIRES :
...                 - Toujours vérifier que le formulaire est visible avant d'écrire (`Wait Until Element Is Visible`).
...                 - Couvrir à la fois le cas nominal (Happy Path) et les cas d'erreur (Negative Testing).
...                 - En Teardown, capturer automatiquement un screenshot si un test échoue.
...               ==============================================================================

Library           SeleniumLibrary
Resource          ../variables.robot
Resource          ../keywords.robot

Suite Setup       Open Browser And Go To Home
Suite Teardown    Close Browser And Cleanup
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Test Cases ***

# ─────────────────────────────────────────────────────────────────────────────
# 1. TESTS DE LA PAGE DE CONNEXION (LOGIN)
# ─────────────────────────────────────────────────────────────────────────────

TC01 - Login Page Loads Correctly
    [Documentation]    Vérifie la présence et la visibilité de chaque champ du formulaire de connexion.
    [Tags]             smoke    auth    login
    Go To                        ${LOGIN_URL}
    Title Should Be              Login — Robot Framework Training
    Element Should Be Visible    id:login-form
    Element Should Be Visible    id:username
    Element Should Be Visible    id:password
    Element Should Be Visible    id:login-submit-btn
    Element Should Be Visible    id:link-register

TC02 - Admin Login Succeeds
    [Documentation]    Cas nominal (Happy Path) : Connexion en tant qu'administrateur.
    ...                L'administrateur doit accéder au dashboard et voir le panneau de gestion admin.
    [Tags]             smoke    auth    login
    Go To                        ${LOGIN_URL}
    Wait Until Element Is Visible    id:login-form
    Input Text                   id:username    ${ADMIN_USER}
    Input Text                   id:password    ${ADMIN_PASS}
    Click Button                 id:login-submit-btn
    Wait Until Element Is Visible    id:dashboard-title    timeout=${DEFAULT_TIMEOUT}
    ${text}=                     Get Text    id:dashboard-title
    Should Contain               ${text}    Admin User
    Element Should Be Visible    id:admin-panel
    Go To                        ${BASE_URL}/logout

TC03 - User1 Login Succeeds
    [Documentation]    Cas nominal : Connexion en tant qu'utilisateur standard (user1).
    ...                Vérifie que l'utilisateur n'a PAS accès au panneau d'administration.
    [Tags]             auth    login
    Go To                        ${LOGIN_URL}
    Wait Until Element Is Visible    id:login-form
    Input Text                   id:username    ${USER1_USER}
    Input Text                   id:password    ${USER1_PASS}
    Click Button                 id:login-submit-btn
    Wait Until Element Is Visible    id:dashboard-title    timeout=${DEFAULT_TIMEOUT}
    ${text}=                     Get Text    id:session-username
    Should Be Equal              ${text}    user1
    Element Should Not Be Visible    id:admin-panel
    Go To                        ${BASE_URL}/logout

TC04 - Login Fails With Wrong Password
    [Documentation]    Cas négatif : Tentative de connexion avec un mot de passe erroné.
    ...                Le système doit refuser l'accès et afficher un message d'erreur explicite.
    [Tags]             auth    login    negative
    Go To                        ${LOGIN_URL}
    Wait Until Element Is Visible    id:login-form
    Input Text                   id:username    ${INVALID_USER}
    Input Text                   id:password    ${INVALID_PASS}
    Click Button                 id:login-submit-btn
    Wait Until Element Is Visible    id:login-error-message    timeout=${DEFAULT_TIMEOUT}
    ${error}=                    Get Text    id:login-error-message
    Should Contain               ${error}    Invalid username or password

TC05 - Login Fails With Unknown Username
    [Documentation]    Cas négatif : Tentative de connexion avec un identifiant qui n'existe pas.
    [Tags]             auth    login    negative
    Go To                        ${LOGIN_URL}
    Wait Until Element Is Visible    id:login-form
    Input Text                   id:username    unknownuser999
    Input Text                   id:password    SomePass123!
    Click Button                 id:login-submit-btn
    Wait Until Element Is Visible    id:login-error-message    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    id:login-form

TC06 - Login With Empty Fields Shows Error
    [Documentation]    Cas négatif : Clic sur Connexion sans remplir les champs obligatoires.
    [Tags]             auth    login    negative
    Go To                        ${LOGIN_URL}
    Wait Until Element Is Visible    id:login-form
    Execute Javascript           document.getElementById('login-form').submit()
    Wait Until Element Is Visible    id:login-error-message    timeout=${DEFAULT_TIMEOUT}

TC07 - Logout Works Correctly
    [Documentation]    Vérifie la déconnexion complète :
    ...                - Clic sur déconnexion -> redirection vers l'accueil avec message flash.
    ...                - Tentative de retour forcé vers le dashboard -> redirection vers /login (protection de session).
    [Tags]             smoke    auth    logout
    Login As Admin
    Click Link                   id:nav-logout
    Wait Until Element Is Visible    id:flash-container    timeout=${DEFAULT_TIMEOUT}
    ${url}=                      Get Location
    Should Be Equal              ${url}    ${BASE_URL}/
    Go To                        ${DASHBOARD_URL}
    ${url}=                      Get Location
    Should Contain               ${url}    /login

TC08 - Session Info Displayed On Dashboard
    [Documentation]    Vérifie que les informations de la session active (nom, username)
    ...                sont correctement réinjectées et affichées dans la vue utilisateur.
    [Tags]             auth    dashboard
    Login As User1
    Element Should Be Visible    id:session-username
    Element Should Be Visible    id:session-name
    ${username}=                 Get Text    id:session-username
    Should Be Equal              ${username}    user1
    ${name}=                     Get Text    id:session-name
    Should Contain               ${name}    Alice
    Go To                        ${BASE_URL}/logout

# ─────────────────────────────────────────────────────────────────────────────
# 2. TESTS DU FORMULAIRE D'INSCRIPTION (REGISTER)
# ─────────────────────────────────────────────────────────────────────────────

TC09 - Register Page Loads Correctly
    [Documentation]    Vérifie que tous les éléments du formulaire de création de compte sont présents.
    [Tags]             auth    register
    Go To                        ${REGISTER_URL}
    Element Should Be Visible    id:register-form
    Element Should Be Visible    id:name
    Element Should Be Visible    id:username
    Element Should Be Visible    id:email
    Element Should Be Visible    id:password
    Element Should Be Visible    id:confirm_password

TC10 - Registration With Mismatched Passwords Shows Error
    [Documentation]    Validation de cohérence : Échec si le mot de passe et sa confirmation diffèrent.
    [Tags]             auth    register    negative
    Go To                        ${REGISTER_URL}
    Wait Until Element Is Visible    id:register-form
    Input Text                   id:name    Test User
    Input Text                   id:username    testuser_rf
    Input Text                   id:email    testuser@example.com
    Input Text                   id:password    Pass123!
    Input Text                   id:confirm_password    Different456!
    Scroll Element Into View     id:register-submit-btn
    Click Button                 id:register-submit-btn
    Wait Until Element Is Visible    id:error-confirm    timeout=${DEFAULT_TIMEOUT}
    ${error}=                    Get Text    id:error-confirm
    Should Contain               ${error}    Passwords do not match

TC11 - Registration With Duplicate Username Shows Error
    [Documentation]    Validation d'unicité : Échec si le nom d'utilisateur est déjà utilisé par un compte existant.
    [Tags]             auth    register    negative
    Go To                        ${REGISTER_URL}
    Wait Until Element Is Visible    id:register-form
    Input Text                   id:name    Admin Copy
    Input Text                   id:username    admin
    Input Text                   id:email    admincopy@example.com
    Input Text                   id:password    Pass123!
    Input Text                   id:confirm_password    Pass123!
    Click Button                 id:register-submit-btn
    Wait Until Element Is Visible    id:error-username    timeout=${DEFAULT_TIMEOUT}
    ${error}=                    Get Text    id:error-username
    Should Contain               ${error}    already taken

TC12 - Registration With Invalid Email Shows Error
    [Documentation]    Validation de format : Échec si l'adresse e-mail n'a pas un format valide.
    [Tags]             auth    register    negative
    Go To                        ${REGISTER_URL}
    Wait Until Element Is Visible    id:register-form
    Input Text                   id:name    Test User
    Input Text                   id:username    validuser123
    Input Text                   id:email    not-an-email
    Input Text                   id:password    Pass123!
    Input Text                   id:confirm_password    Pass123!
    Click Button                 id:register-submit-btn
    Wait Until Element Is Visible    id:error-email    timeout=${DEFAULT_TIMEOUT}

TC13 - Successful Registration Redirects To Login
    [Documentation]    Cas nominal complet d'inscription :
    ...                - Utilise Python 'Evaluate' pour générer un nom d'utilisateur dynamique et unique.
    ...                - Soumet le formulaire et vérifie la redirection vers la page de login avec succès.
    [Tags]             auth    register
    ${unique}=                   Evaluate    'rftest' + str(int(time.time()))    modules=time
    Go To                        ${REGISTER_URL}
    Wait Until Element Is Visible    id:register-form
    Input Text                   id:name    Robot Tester
    Input Text                   id:username    ${unique}
    Input Text                   id:email    ${unique}@example.com
    Input Text                   id:password    Pass123!
    Input Text                   id:confirm_password    Pass123!
    Click Button                 id:register-submit-btn
    Wait Until Element Is Visible    id:login-form    timeout=${DEFAULT_TIMEOUT}
    Flash Message Should Be Visible    Account created

# ─────────────────────────────────────────────────────────────────────────────
# 3. TESTS DU FORMULAIRE DE CONTACT (WIDGETS VARIÉS)
# ─────────────────────────────────────────────────────────────────────────────

TC14 - Contact Form Submits Successfully
    [Documentation]    Teste la soumission réussie d'un formulaire riche comprenant :
    ...                - Champs texte (Nom, prénom, e-mail, message)
    ...                - Liste déroulante (Select From List By Value)
    ...                - Bouton radio personnalisé (Rating étoiles)
    ...                - Case à cocher (Checkbox newsletter)
    [Tags]             forms    contact
    Go To                        ${CONTACT_URL}
    Wait Until Element Is Visible    id:contact-form
    Input Text                   id:first_name    Robot
    Input Text                   id:last_name    Tester
    Input Text                   id:email    robot@test.com
    Select From List By Value    id:subject    general
    Input Text                   id:message    This is a test message from Robot Framework, more than 10 chars.
    Scroll Element Into View     id:contact-submit-btn
    Click Element                xpath://label[@for='rating-4']
    Select Checkbox              id:newsletter
    Click Button                 id:contact-submit-btn
    Wait Until Element Is Visible    id:contact-success-message    timeout=${DEFAULT_TIMEOUT}
    ${msg}=                      Get Text    id:contact-success-message
    Should Contain               ${msg}    sent successfully

TC15 - Contact Form Shows Errors For Empty Fields
    [Documentation]    Vérifie que la soumission sans saisie déclenche les messages d'erreur requis pour chaque champ.
    [Tags]             forms    contact    negative
    Go To                        ${CONTACT_URL}
    Wait Until Element Is Visible    id:contact-form
    Scroll Element Into View     id:contact-submit-btn
    Click Button                 id:contact-submit-btn
    Wait Until Element Is Visible    id:error-first-name    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    id:error-last-name
    Element Should Be Visible    id:error-email
    Element Should Be Visible    id:error-subject
    Element Should Be Visible    id:error-message

TC16 - Contact Form Rating Can Be Selected
    [Documentation]    Illustration de la boucle FOR en Robot Framework :
    ...                Itère sur les notes de 1 à 5, clique sur chaque label de radio
    ...                et valide que le radio correspondant est sélectionné.
    [Tags]             forms    contact
    Go To                        ${CONTACT_URL}
    Wait Until Element Is Visible    id:contact-form
    Scroll Element Into View     id:rating-group
    FOR    ${i}    IN    1    2    3    4    5
        Click Element            xpath://label[@for='rating-${i}']
        Radio Button Should Be Set To    rating    ${i}
    END

TC17 - Newsletter Checkbox Can Be Toggled
    [Documentation]    Vérifie la manipulation d'une case à cocher (sélection et désélection) :
    ...                - Checkbox Should Not Be Selected
    ...                - Select Checkbox
    ...                - Unselect Checkbox
    [Tags]             forms    contact
    Go To                        ${CONTACT_URL}
    Wait Until Element Is Visible    id:contact-form
    Scroll Element Into View     id:newsletter
    Checkbox Should Not Be Selected    id:newsletter
    Select Checkbox              id:newsletter
    Checkbox Should Be Selected  id:newsletter
    Unselect Checkbox            id:newsletter
    Checkbox Should Not Be Selected    id:newsletter
