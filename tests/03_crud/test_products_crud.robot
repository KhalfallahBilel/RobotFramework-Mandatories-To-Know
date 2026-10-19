*** Settings ***
Documentation     ==============================================================================
...               SUITE 03 — GESTION DE PRODUITS : CYCLE COMPLET CRUD & CONTRÔLE D'ACCÈS
...               ==============================================================================
...               Cette suite illustre l'automatisation d'un cycle de gestion de données complet :
...                 - READ   : Affichage de la grille de produits, filtres par catégorie, recherche textuelle,
...                            page détail d'un produit, badges d'état (ex: Rupture de stock).
...                 - CREATE : Ajout d'un nouveau produit avec validation des champs obligatoires (nom, prix).
...                 - UPDATE : Modification des informations d'un produit existant (champs pré-remplis, sauvegarde).
...                 - DELETE : Suppression avec confirmation par boîte de dialogue JavaScript (Handle Alert).
...                 - RBAC   : Contrôle d'accès basé sur les rôles (l'admin a les boutons d'action, pas l'utilisateur).
...
...               💡 TECHNIQUES AVANCÉES SELENIUM DEMONSTRÉES :
...                 - 'Clear Element Text' : efface le champ avant d'écrire une nouvelle valeur.
...                 - 'Handle Alert' : intercepte et clique sur 'OK' dans une boîte confirm() JavaScript.
...                 - 'Get Element Attribute' : récupère dynamiquement l'attribut 'id' d'un élément dans le DOM.
...                 - 'Evaluate' : exécute une petite expression Python pour découper une chaîne de caractères.
...               ==============================================================================

Library           SeleniumLibrary
Resource          ../variables.robot
Resource          ../keywords.robot

Suite Setup       Run Keywords    Open Browser And Go To Home    AND    Login As Admin
Suite Teardown    Run Keywords    Logout    AND    Close Browser And Cleanup
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Variables ***
# Variables spécifiques à cette suite pour tester la création et modification
${TEST_PRODUCT_NAME}     RF Auto Monitor 27
${TEST_PRODUCT_EDIT}     RF Auto Monitor 27 Pro Updated

*** Test Cases ***

# ─────────────────────────────────────────────────────────────────────────────
# 1. READ — CONSULTATION & RECHERCHE DE PRODUITS
# ─────────────────────────────────────────────────────────────────────────────

TC01 - Products List Page Shows All Products
    [Documentation]    Vérifie que la page affiche la grille de produits et les cartes d'articles.
    [Tags]             crud    read    smoke
    Go To                        ${PRODUCTS_URL}
    Wait Until Element Is Visible    id:products-grid
    Element Should Be Visible    id:product-card-1
    Element Should Be Visible    id:product-card-2
    Page Should Contain          Laptop Pro 15
    Page Should Contain          Wireless Mouse

TC02 - Search Filters Products By Name
    [Documentation]    Teste le filtre de recherche par mot-clé :
    ...                Saisit 'Laptop', valide le formulaire et vérifie que seul 'Laptop Pro 15'
    ...                reste affiché tandis que 'Wireless Mouse' disparaît de l'écran.
    [Tags]             crud    read    search
    Go To                        ${PRODUCTS_URL}
    Input Text                   id:search-input    Laptop
    Click Button                 id:btn-filter
    Wait Until Page Contains     Laptop Pro 15
    Page Should Not Contain      Wireless Mouse

TC03 - Category Filter Works
    [Documentation]    Teste le filtre par liste déroulante de catégorie :
    ...                Sélectionne 'Accessories' et valide que seuls les accessoires apparaissent.
    [Tags]             crud    read    search
    Go To                        ${PRODUCTS_URL}
    Select From List By Value    id:category-filter    Accessories
    Click Button                 id:btn-filter
    Wait Until Page Contains     Wireless Mouse
    Page Should Not Contain      Laptop Pro 15

TC04 - Clear Filter Restores All Products
    [Documentation]    Vérifie que le bouton de réinitialisation des filtres remet l'affichage de tous les produits.
    [Tags]             crud    read    search
    Go To                        ${PRODUCTS_URL}?search=Laptop
    Wait Until Element Is Visible    id:btn-clear-filter
    Click Link                   id:btn-clear-filter
    Wait Until Page Contains     Wireless Mouse
    Page Should Contain          Laptop Pro 15

TC05 - Product Detail Page Shows All Fields
    [Documentation]    Vérifie l'affichage complet de la fiche détaillée d'un produit (nom, prix, stock, catégorie).
    [Tags]             crud    read
    Go To                        ${PRODUCTS_URL}/1
    Wait Until Element Is Visible    id:product-detail-card
    Element Should Be Visible    id:detail-name
    Element Should Be Visible    id:detail-price
    Element Should Be Visible    id:detail-stock
    Element Should Be Visible    id:detail-category
    ${name}=                     Get Text    id:detail-name
    Should Be Equal              ${name}    Laptop Pro 15

TC06 - Out Of Stock Product Shows Correct Badge
    [Documentation]    Vérifie la mise en valeur conditionnelle : le produit 5 a un stock de 0
    ...                et doit arborer le badge CSS 'badge-danger' avec la mention 'Out of Stock'.
    [Tags]             crud    read
    Go To                        ${PRODUCTS_URL}/5
    Wait Until Element Is Visible    id:detail-stock
    Element Should Be Visible    xpath://span[contains(@class,'badge-danger') and contains(text(),'Out of Stock')]

# ─────────────────────────────────────────────────────────────────────────────
# 2. CREATE — AJOUT DE NOUVEAUX PRODUITS
# ─────────────────────────────────────────────────────────────────────────────

TC07 - Admin Can See Add Product Button
    [Documentation]    Vérifie que le bouton d'ajout de produit est bien visible pour le profil Administrateur.
    [Tags]             crud    create    admin
    Go To                        ${PRODUCTS_URL}
    Element Should Be Visible    id:btn-add-product

TC08 - Create New Product Successfully
    [Documentation]    Crée un nouveau produit complet :
    ...                Remplit le formulaire, clique sur enregistrer et vérifie le message de confirmation
    ...                ainsi que l'apparition du produit dans la liste.
    [Tags]             crud    create    smoke
    Go To                        ${PRODUCTS_URL}/new
    Wait Until Element Is Visible    id:product-form
    Input Text                   id:name    ${TEST_PRODUCT_NAME}
    Select From List By Value    id:category    Electronics
    Input Text                   id:price    99.99
    Input Text                   id:stock    50
    Input Text                   id:description    Créé automatiquement par les tests Robot Framework
    Click Button                 id:product-submit-btn
    Wait Until Element Is Visible    id:products-grid    timeout=${DEFAULT_TIMEOUT}
    Flash Message Should Be Visible    created successfully
    Page Should Contain          ${TEST_PRODUCT_NAME}

TC09 - Create Product With Empty Name Shows Error
    [Documentation]    Contrôle de validation négative : Le champ nom est obligatoire.
    [Tags]             crud    create    negative
    Go To                        ${PRODUCTS_URL}/new
    Input Text                   id:price    10.00
    Input Text                   id:stock    5
    Click Button                 id:product-submit-btn
    Wait Until Element Is Visible    id:error-name
    ${error}=                    Get Text    id:error-name
    Should Contain               ${error}    required

TC10 - Create Product With Invalid Price Shows Error
    [Documentation]    Contrôle de validation négative : Le prix ne peut pas être négatif.
    [Tags]             crud    create    negative
    Go To                        ${PRODUCTS_URL}/new
    Input Text                   id:name    Bad Price Product
    Select From List By Value    id:category    Electronics
    Input Text                   id:price    -5
    Input Text                   id:stock    10
    Click Button                 id:product-submit-btn
    Wait Until Element Is Visible    id:error-price

# ─────────────────────────────────────────────────────────────────────────────
# 3. UPDATE — ÉDITION ET MODIFICATION
# ─────────────────────────────────────────────────────────────────────────────

TC11 - Edit Product Page Pre-Fills Form
    [Documentation]    Vérifie que la page d'édition charge bien les valeurs actuelles du produit dans les champs.
    [Tags]             crud    update
    Go To                        ${PRODUCTS_URL}/1/edit
    Wait Until Element Is Visible    id:product-form
    ${name}=                     Get Value    id:name
    Should Be Equal              ${name}    Laptop Pro 15
    ${price}=                    Get Value    id:price
    Should Contain               ${price}    1299

TC12 - Edit Product Updates Successfully
    [Documentation]    Modifie le nom et le stock du produit créé précédemment au TC08 :
    ...                1. Localise la carte du produit et clique directement sur son bouton 'Edit'.
    ...                2. Utilise 'Clear Element Text' pour vider les champs avant de renseigner les nouvelles valeurs.
    ...                3. Valide que le produit affiche désormais son nouveau nom.
    [Tags]             crud    update
    Go To                        ${PRODUCTS_URL}
    Wait Until Page Contains     ${TEST_PRODUCT_NAME}
    Scroll Element Into View     xpath://div[contains(@class,'product-card') and .//div[contains(@class,'product-name') and contains(text(), '${TEST_PRODUCT_NAME}')]]//a[contains(@id,'btn-edit-')]
    Click Link                   xpath://div[contains(@class,'product-card') and .//div[contains(@class,'product-name') and contains(text(), '${TEST_PRODUCT_NAME}')]]//a[contains(@id,'btn-edit-')]
    Wait Until Element Is Visible    id:product-form    timeout=${DEFAULT_TIMEOUT}
    Clear Element Text           id:name
    Input Text                   id:name    ${TEST_PRODUCT_EDIT}
    Clear Element Text           id:stock
    Input Text                   id:stock    75
    Click Button                 id:product-submit-btn
    Wait Until Page Contains     ${TEST_PRODUCT_EDIT}    timeout=${DEFAULT_TIMEOUT}

# ─────────────────────────────────────────────────────────────────────────────
# 4. DELETE — SUPPRESSION ET GESTION DES BOÎTES DE DIALOGUE
# ─────────────────────────────────────────────────────────────────────────────

TC13 - Product Shows Delete Button For Admin
    [Documentation]    S'assure que le bouton de suppression est disponible pour l'administrateur.
    [Tags]             crud    delete    admin
    Go To                        ${PRODUCTS_URL}
    Element Should Be Visible    id:btn-delete-1

TC14 - Delete The Test Product
    [Documentation]    Supprime le produit créé lors des tests :
    ...                1. Clique sur le bouton de suppression du produit modifié.
    ...                2. Gère la boîte de confirmation native du navigateur via 'Handle Alert action=ACCEPT'.
    ...                3. Vérifie que le produit n'apparaît plus dans la page.
    [Tags]             crud    delete
    Go To                        ${PRODUCTS_URL}
    Wait Until Page Contains     ${TEST_PRODUCT_EDIT}
    Scroll Element Into View     xpath://div[contains(@class,'product-card') and .//div[contains(@class,'product-name') and contains(text(), '${TEST_PRODUCT_EDIT}')]]//button[contains(@id,'btn-delete-')]
    Click Button                 xpath://div[contains(@class,'product-card') and .//div[contains(@class,'product-name') and contains(text(), '${TEST_PRODUCT_EDIT}')]]//button[contains(@id,'btn-delete-')]
    Handle Alert                 action=ACCEPT
    Wait Until Page Contains     deleted    timeout=${DEFAULT_TIMEOUT}
    Page Should Not Contain      ${TEST_PRODUCT_EDIT}

# ─────────────────────────────────────────────────────────────────────────────
# 5. CONTRÔLE DES ACCÈS & SÉCURITÉ (RBAC)
# ─────────────────────────────────────────────────────────────────────────────

TC15 - Regular User Cannot See Admin Controls
    [Documentation]    Vérifie qu'un utilisateur standard connecté (user1) ne voit ni le bouton
    ...                d'ajout de produit ni les boutons de suppression dans la grille.
    [Tags]             crud    security
    Go To                        ${BASE_URL}/logout
    Login As User1
    Go To                        ${PRODUCTS_URL}
    Wait Until Element Is Visible    id:products-grid
    # Contrôles de sécurité stricts
    Element Should Not Be Visible    id:btn-add-product
    Element Should Not Be Visible    id:btn-delete-1
    Go To                        ${BASE_URL}/logout
    Login As Admin
