*** Settings ***
Documentation     ==============================================================================
...               SUITE 04 — TESTS D'API REST (SANS NAVIGATEUR)
...               ==============================================================================
...               Cette suite teste l'ensemble des endpoints de l'API REST avec 'RequestsLibrary'.
...
...               💡 POURQUOI DES TESTS D'API ?
...                 - VITESSE : Ces 13 tests s'exécutent en moins de 1 seconde (contre ~20s avec un navigateur).
...                 - ROBUSTESSE : Pas de problème de rendu CSS, de fenêtre ou de temps de chargement visuel.
...                 - COUVERTURE : Permet de tester les statuts HTTP (200, 201, 400, 404), les schémas JSON,
...                   les en-têtes (Content-Type) et les opérations CRUD côté backend.
...
...               💡 MOTS-CLÉS CLÉS DE REQUESTSLIBRARY & COLLECTIONS :
...                 - 'Create Session'        : Ouvre une session HTTP réutilisable vers le serveur hôte.
...                 - 'GET / POST / PUT / DELETE On Session' : Exécute la requête HTTP associée.
...                 - 'Dictionary Should Contain Key'        : Valide la présence d'une clé dans un objet JSON.
...                 - 'Set Suite Variable'    : Partage une valeur (ex: un ID créé) entre plusieurs tests de la suite.
...               ==============================================================================

# Bibliothèques nécessaires pour requêter les API et manipuler les dictionnaires / listes JSON
Library           RequestsLibrary
Library           Collections
Resource          ../variables.robot

# Initialisation : Crée la session HTTP nommée 'robotapp' vers l'URL de base (port 5001)
Suite Setup       Create Session    robotapp    ${BASE_URL}    verify=${False}

# Nettoyage : Ferme les sessions HTTP à la fin de la suite
Suite Teardown    Delete All Sessions

*** Variables ***
# ID temporaire qui sera alimenté lors de la création d'un produit (TC05) et réutilisé pour la suppression (TC09)
${CREATED_PRODUCT_ID}    ${EMPTY}

*** Test Cases ***

# ─────────────────────────────────────────────────────────────────────────────
# 1. STATUS & MONITORING API
# ─────────────────────────────────────────────────────────────────────────────

TC01 - API Status Returns 200 OK
    [Documentation]    Interroge /api/status et vérifie :
    ...                - Le code HTTP 200 (Succès).
    ...                - Le statut 'ok' dans le corps JSON.
    ...                - La présence des clés obligatoires 'timestamp' et 'version'.
    [Tags]             api    smoke
    ${response}=                 GET On Session    robotapp    /api/status    expected_status=200
    Should Be Equal As Strings   ${response.status_code}    200
    # Conversion de la réponse texte en dictionnaire JSON Python
    ${body}=                     Set Variable    ${response.json()}
    Should Be Equal              ${body}[status]    ok
    Dictionary Should Contain Key    ${body}    timestamp
    Dictionary Should Contain Key    ${body}    version

# ─────────────────────────────────────────────────────────────────────────────
# 2. CONSULTATION (GET) DES PRODUITS
# ─────────────────────────────────────────────────────────────────────────────

TC02 - API Products Returns List
    [Documentation]    Interroge /api/products et s'assure qu'une liste non vide d'au moins 5 articles est renvoyée.
    [Tags]             api    smoke
    ${response}=                 GET On Session    robotapp    /api/products    expected_status=200
    ${body}=                     Set Variable    ${response.json()}
    Should Not Be Empty          ${body}
    ${length}=                   Get Length    ${body}
    Should Be True               ${length} >= 5    La liste devrait contenir au moins 5 produits de démonstration

TC03 - API Get Single Product
    [Documentation]    Récupère un produit spécifique par son identifiant (/api/products/1) et valide ses attributs.
    [Tags]             api
    ${response}=                 GET On Session    robotapp    /api/products/1    expected_status=200
    ${body}=                     Set Variable    ${response.json()}
    Should Be Equal              ${body}[id]    1
    Should Be Equal              ${body}[name]    Laptop Pro 15
    Dictionary Should Contain Key    ${body}    price
    Dictionary Should Contain Key    ${body}    stock
    Dictionary Should Contain Key    ${body}    category

TC04 - API Get Non-Existent Product Returns 404
    [Documentation]    Cas d'erreur : Vérifie qu'un identifiant inexistant (/api/products/9999) renvoie le code HTTP 404 Not Found.
    [Tags]             api    negative
    ${response}=                 GET On Session    robotapp    /api/products/9999    expected_status=404
    ${body}=                     Set Variable    ${response.json()}
    Should Be Equal              ${body}[error]    Not found

# ─────────────────────────────────────────────────────────────────────────────
# 3. CRÉATION (POST) D'UN PRODUIT
# ─────────────────────────────────────────────────────────────────────────────

TC05 - API Create Product With Valid Data
    [Documentation]    Envoie une requête POST avec un payload JSON complet.
    ...                Vérifie le code 201 Created et enregistre l'ID généré dans une variable de suite.
    [Tags]             api    create
    # Construction du dictionnaire JSON à envoyer
    ${data}=                     Create Dictionary
    ...    name=API Test Product
    ...    category=Electronics
    ...    price=${49.99}
    ...    stock=${100}
    ...    description=Créé via requête HTTP Robot Framework
    ${response}=                 POST On Session    robotapp    /api/products    json=${data}    expected_status=201
    ${body}=                     Set Variable    ${response.json()}
    Should Be Equal              ${body}[name]    API Test Product
    Should Be Equal As Numbers   ${body}[price]    49.99
    # Mémorisation de l'ID créé pour les tests ultérieurs
    ${created_id}=               Set Variable    ${body}[id]
    Set Suite Variable           ${CREATED_PRODUCT_ID}    ${created_id}

TC06 - API Create Product Without Name Returns 400
    [Documentation]    Validation de schéma : Envoi d'une requête POST incomplète sans nom -> doit renvoyer 400 Bad Request.
    [Tags]             api    create    negative
    ${data}=                     Create Dictionary    price=${10.00}    stock=${5}
    ${response}=                 POST On Session    robotapp    /api/products    json=${data}    expected_status=400
    ${body}=                     Set Variable    ${response.json()}
    Should Be Equal              ${body}[error]    Name is required

# ─────────────────────────────────────────────────────────────────────────────
# 4. MODIFICATION (PUT) D'UN PRODUIT
# ─────────────────────────────────────────────────────────────────────────────

TC07 - API Update Product
    [Documentation]    Met à jour un produit existant via une requête PUT et valide la modification.
    ...                Restaure ensuite la valeur d'origine pour ne pas polluer l'environnement.
    [Tags]             api    update
    ${data}=                     Create Dictionary    name=Laptop Pro 15 (Updated)    price=${1399.99}
    ${response}=                 PUT On Session    robotapp    /api/products/1    json=${data}    expected_status=200
    ${body}=                     Set Variable    ${response.json()}
    Should Contain               ${body}[name]    Updated
    Should Be Equal As Numbers   ${body}[price]    1399.99
    # Rétablissement de la valeur initiale
    ${restore}=                  Create Dictionary    name=Laptop Pro 15    price=${1299.99}
    PUT On Session               robotapp    /api/products/1    json=${restore}

TC08 - API Update Non-Existent Product Returns 404
    [Documentation]    Vérifie qu'une mise à jour (PUT) sur un ID inexistant retourne bien 404.
    [Tags]             api    update    negative
    ${data}=                     Create Dictionary    name=Ghost Product
    ${response}=                 PUT On Session    robotapp    /api/products/9999    json=${data}    expected_status=404

# ─────────────────────────────────────────────────────────────────────────────
# 5. SUPPRESSION (DELETE) D'UN PRODUIT
# ─────────────────────────────────────────────────────────────────────────────

TC09 - API Delete Created Product
    [Documentation]    Supprime le produit préalablement créé au TC05 via une requête HTTP DELETE.
    [Tags]             api    delete
    ${response}=                 DELETE On Session    robotapp    /api/products/${CREATED_PRODUCT_ID}    expected_status=200
    ${body}=                     Set Variable    ${response.json()}
    Should Be Equal              ${body}[message]    Deleted

TC10 - API Delete Non-Existent Product Returns 404
    [Documentation]    Vérifie qu'une tentative de suppression (DELETE) sur un ID inexistant renvoie 404.
    [Tags]             api    delete    negative
    ${response}=                 DELETE On Session    robotapp    /api/products/9999    expected_status=404

# ─────────────────────────────────────────────────────────────────────────────
# 6. AUTRES ENDPOINTS & CONTRÔLE DE CONFORMITÉ
# ─────────────────────────────────────────────────────────────────────────────

TC11 - API Contacts Returns List
    [Documentation]    Vérifie que l'endpoint /api/contacts renvoie une liste de messages de contact.
    [Tags]             api
    ${response}=                 GET On Session    robotapp    /api/contacts    expected_status=200
    ${body}=                     Set Variable    ${response.json()}
    Should Be True               isinstance($body, list)

TC12 - API Products Have Required Fields
    [Documentation]    Vérifie que chaque objet produit dans la liste respecte la structure attendue
    ...                en itérant sur chacun avec une boucle FOR et 'Dictionary Should Contain Key'.
    [Tags]             api    schema
    ${response}=                 GET On Session    robotapp    /api/products
    ${products}=                 Set Variable    ${response.json()}
    FOR    ${product}    IN    @{products}
        Dictionary Should Contain Key    ${product}    id
        Dictionary Should Contain Key    ${product}    name
        Dictionary Should Contain Key    ${product}    price
        Dictionary Should Contain Key    ${product}    stock
        Dictionary Should Contain Key    ${product}    category
    END

TC13 - API Response Content Type Is JSON
    [Documentation]    Vérifie que les en-têtes HTTP de la réponse spécifient bien 'application/json'.
    [Tags]             api    headers
    ${response}=                 GET On Session    robotapp    /api/products
    ${content_type}=             Get From Dictionary    ${response.headers}    Content-Type
    Should Contain               ${content_type}    application/json
