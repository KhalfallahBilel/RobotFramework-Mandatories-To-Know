*** Settings ***
Documentation     ==============================================================================
...               SUITE 05 — COMPOSANTS MODERNES & INTERACTIONS DYNAMIQUES AVANCÉES
...               ==============================================================================
...               Cette suite aborde les défis classiques de l'automatisation front-end moderne :
...                 1. SYSTÈMES D'ONGLETS (Tabs) : bascule de contenu sans recharger la page.
...                 2. ACCORDÉONS DÉPLIANTS (Accordions/FAQ) : déploiement et fermeture exclusive.
...                 3. FENÊTRES MODALES (Popups) : ouverture, backdrop overlay, formulaires embarqués,
...                    fermeture par bouton ou clic extérieur.
...                 4. ÉLÉMENTS DYNAMIQUES & ASYNCHRONES :
...                    - Chargement avec délai simulé (AJAX / setTimeout).
...                    - Gestion des indicateurs d'attente (Spinners) qui apparaissent puis disparaissent.
...                    - Ajout dynamique d'éléments dans une liste sans rafraîchissement.
...                    - Pagination côté client avec état des boutons (disabled / enabled).
...                 5. TABLEAUX DE DONNÉES AVANCÉS :
...                    - Filtrage dynamique par frappe au clavier (Live Search).
...                    - Tri des colonnes par clic d'en-tête (Sortable columns).
...                    - Cartes de statistiques et métriques résumées.
...
...               💡 MAÎTRISE DES ATTENTES EXPLICITES :
...                 - 'Wait Until Element Is Visible'     : attend que l'élément soit affiché à l'écran.
...                 - 'Wait Until Element Is Not Visible' : attend qu'un spinner ou modal disparaisse.
...                 - Ne jamais abuser de 'Sleep' statique ! Les attentes conditionnelles rendent
...                   les tests 5x plus rapides et 100% fiables.
...               ==============================================================================

Library           SeleniumLibrary
Resource          ../variables.robot
Resource          ../keywords.robot

Suite Setup       Open Browser And Go To Home
Suite Teardown    Close Browser And Cleanup
Test Teardown     Run Keyword If Test Failed    Capture Page Screenshot

*** Test Cases ***

# ─────────────────────────────────────────────────────────────────────────────
# 1. SYSTÈME D'ONGLETS (TABS)
# ─────────────────────────────────────────────────────────────────────────────

TC01 - Tabs Are Present On Alerts Page
    [Documentation]    Vérifie la présence des 4 onglets : Vue d'ensemble, Détails, Paramètres et API.
    [Tags]             advanced    tabs    smoke
    Go To                        ${ALERTS_URL}
    Element Should Be Visible    id:tab-btn-overview
    Element Should Be Visible    id:tab-btn-details
    Element Should Be Visible    id:tab-btn-settings
    Element Should Be Visible    id:tab-btn-api

TC02 - First Tab Is Active By Default
    [Documentation]    Vérifie que le premier onglet est actif par défaut et que les autres sont cachés.
    [Tags]             advanced    tabs
    Go To                        ${ALERTS_URL}
    Element Should Be Visible    id:tab-overview-card
    # L'onglet de détails ne doit pas encore être affiché
    Element Should Not Be Visible    id:tab-details

TC03 - Clicking Tab Switches Content
    [Documentation]    Bascule d'onglet en cliquant sur 'Details' et valide l'apparition du panneau associé.
    [Tags]             advanced    tabs
    Go To                        ${ALERTS_URL}
    Click Button                 id:tab-btn-details
    Wait Until Element Is Visible    id:details-list    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    id:details-list

TC04 - Settings Tab Contains Checkboxes
    [Documentation]    Vérifie le contenu interactif (cases à cocher de configuration) dans l'onglet Paramètres.
    [Tags]             advanced    tabs
    Go To                        ${ALERTS_URL}
    Click Button                 id:tab-btn-settings
    Wait Until Element Is Visible    id:setting-notifications
    Element Should Be Visible    id:setting-dark
    Checkbox Should Be Selected  id:setting-notifications

# ─────────────────────────────────────────────────────────────────────────────
# 2. ACCORDÉONS DÉPLIANTS (ACCORDIONS)
# ─────────────────────────────────────────────────────────────────────────────

TC05 - Accordion Items Are Collapsed By Default
    [Documentation]    Vérifie que les sections d'accordéon sont toutes repliées au chargement de la page.
    [Tags]             advanced    accordion
    Go To                        ${ALERTS_URL}
    Element Should Not Be Visible    id:faq-body-1

TC06 - Click Accordion Opens Item
    [Documentation]    Clique sur l'en-tête du premier bloc FAQ pour le déplier et vérifie son contenu textuel.
    [Tags]             advanced    accordion
    Go To                        ${ALERTS_URL}
    Click Button                 id:faq-header-1
    Wait Until Element Is Visible    id:faq-body-1    timeout=${DEFAULT_TIMEOUT}
    Page Should Contain          open source automation framework

TC07 - Opening Second Accordion Closes First
    [Documentation]    Vérifie le comportement d'accordéon exclusif :
    ...                L'ouverture du second élément doit automatiquement replier le premier élément.
    [Tags]             advanced    accordion
    Go To                        ${ALERTS_URL}
    Click Button                 id:faq-header-1
    Wait Until Element Is Visible    id:faq-body-1
    Click Button                 id:faq-header-2
    Wait Until Element Is Visible    id:faq-body-2
    Element Should Not Be Visible    id:faq-body-1

# ─────────────────────────────────────────────────────────────────────────────
# 3. FENÊTRES MODALES (MODALS / POPUPS)
# ─────────────────────────────────────────────────────────────────────────────

TC08 - Info Modal Opens And Closes
    [Documentation]    Teste l'ouverture d'une fenêtre modale informative puis sa fermeture via le bouton 'OK'.
    [Tags]             advanced    modals    smoke
    Go To                        ${ALERTS_URL}
    Click Button                 id:btn-open-modal-info
    Wait Until Element Is Visible    id:modal-info    timeout=${DEFAULT_TIMEOUT}
    Element Should Be Visible    id:modal-info-title
    ${title}=                    Get Text    id:modal-info-title
    Should Contain               ${title}    Information
    Click Button                 id:modal-info-btn-ok
    # Attend la disparition complète de la modale
    Wait Until Element Is Not Visible    id:modal-info    timeout=${DEFAULT_TIMEOUT}

TC09 - Confirm Modal Has Two Action Buttons
    [Documentation]    Vérifie une modale de confirmation à deux boutons (Confirmer / Annuler).
    [Tags]             advanced    modals
    Go To                        ${ALERTS_URL}
    Click Button                 id:btn-open-modal-confirm
    Wait Until Element Is Visible    id:modal-confirm
    Element Should Be Visible    id:modal-confirm-yes
    Element Should Be Visible    id:modal-confirm-no
    Click Button                 id:modal-confirm-no
    Wait Until Element Is Not Visible    id:modal-confirm

TC10 - Form Modal Can Be Filled And Submitted
    [Documentation]    Vérifie qu'un formulaire complet peut être rempli à l'intérieur d'une modale
    ...                puis soumis sans provoquer d'erreur d'affichage.
    [Tags]             advanced    modals
    Go To                        ${ALERTS_URL}
    Click Button                 id:btn-open-modal-form
    Wait Until Element Is Visible    id:modal-form
    Input Text                   id:modal-note-title    My Robot Note
    Input Text                   id:modal-note-body    Written by Robot Framework!
    Click Button                 id:modal-form-submit
    Wait Until Element Is Not Visible    id:modal-form

TC11 - Modal Closes When Clicking Overlay
    [Documentation]    Vérifie la fermeture de la modale par clic sur la zone d'arrière-plan semi-transparente (backdrop).
    [Tags]             advanced    modals
    Go To                        ${ALERTS_URL}
    Click Button                 id:btn-open-modal-info
    Wait Until Element Is Visible    id:modal-info
    # Clic en dehors du centre de la modale
    Click Element At Coordinates    id:modal-info    -200    0
    Wait Until Element Is Not Visible    id:modal-info

# ─────────────────────────────────────────────────────────────────────────────
# 4. COMPOSANTS DYNAMIQUES ET ATTENTES ASYNCHRONES
# ─────────────────────────────────────────────────────────────────────────────

TC12 - Delayed Element Appears After Button Click
    [Documentation]    Simule une requête lente : clique sur le bouton et attend l'apparition du résultat.
    ...                Démontre l'utilité d'un timeout adapté (${LONG_TIMEOUT}).
    [Tags]             advanced    dynamic    waits
    Go To                        ${DYNAMIC_URL}
    Element Should Not Be Visible    id:delayed-result
    Click Button                 id:btn-load-delayed
    Wait Until Element Is Visible    id:delayed-message    timeout=${LONG_TIMEOUT}
    ${text}=                     Get Text    id:delayed-message
    Should Contain               ${text}    loaded after delay

TC13 - Toggle Element Visibility
    [Documentation]    Vérifie le masquage et l'affichage alternatif (Toggle Show / Hide) d'un élément.
    [Tags]             advanced    dynamic
    Go To                        ${DYNAMIC_URL}
    Element Should Not Be Visible    id:hidden-element
    Click Button                 id:btn-toggle-element
    Wait Until Element Is Visible    id:hidden-element    timeout=${SHORT_TIMEOUT}
    Click Button                 id:btn-toggle-element
    Wait Until Element Is Not Visible    id:hidden-element    timeout=${SHORT_TIMEOUT}

TC14 - Spinner Disappears After Loading
    [Documentation]    Cycle complet de chargement avec indicateur visuel (Spinner) :
    ...                1. Clic sur le déclencheur.
    ...                2. Attente de l'apparition du spinner.
    ...                3. Attente de la disparition du spinner.
    ...                4. Vérification que le bloc de résultat final est affiché.
    [Tags]             advanced    dynamic    waits
    Go To                        ${DYNAMIC_URL}
    Click Button                 id:btn-show-spinner
    Wait Until Element Is Visible    id:loading-spinner    timeout=${SHORT_TIMEOUT}
    Wait Until Element Is Not Visible    id:loading-spinner    timeout=${LONG_TIMEOUT}
    Wait Until Element Is Visible    id:spinner-success    timeout=${SHORT_TIMEOUT}

TC15 - Dynamic List Add Items
    [Documentation]    Vérifie l'ajout incrémental d'éléments dans une liste HTML via JavaScript :
    ...                Lit le compteur d'éléments avant, saisit un texte, clique sur 'Ajouter',
    ...                et valide que le compteur augmente de 1.
    [Tags]             advanced    dynamic
    Go To                        ${DYNAMIC_URL}
    ${count_before}=             Get Text    id:list-count
    Should Be Equal              ${count_before}    2
    Input Text                   id:new-item-input    Robot Item A
    Click Button                 id:btn-add-item
    ${count_after}=              Get Text    id:list-count
    Should Be Equal              ${count_after}    3
    Page Should Contain Element  id:list-item-3
    Input Text                   id:new-item-input    Robot Item B
    Click Button                 id:btn-add-item
    ${count_final}=              Get Text    id:list-count
    Should Be Equal              ${count_final}    4

TC16 - Pagination Changes Content
    [Documentation]    Teste une pagination dynamique à 3 pages :
    ...                Vérifie l'état 'disabled' du bouton Précédent sur la page 1,
    ...                avance à la page 2 puis 3, vérifie le bouton Suivant désactivé sur la dernière page.
    [Tags]             advanced    pagination
    Go To                        ${DYNAMIC_URL}
    Element Should Be Visible    id:page-item-1
    # Vérification de l'attribut disabled sur le bouton précédent
    ${prev_btn}=                 Get Element Attribute    id:page-prev    disabled
    Should Be Equal              ${prev_btn}    true
    Click Button                 id:page-next
    Wait Until Page Contains     Page 2 of 3
    Element Should Be Visible    id:page-item-7
    Click Button                 id:page-next
    Wait Until Page Contains     Page 3 of 3
    # Le bouton suivant doit maintenant être désactivé
    ${next_btn}=                 Get Element Attribute    id:page-next    disabled
    Should Be Equal              ${next_btn}    true
    Click Button                 id:page-prev
    Wait Until Page Contains     Page 2 of 3

# ─────────────────────────────────────────────────────────────────────────────
# 5. TABLEAU DE DONNÉES AVANCÉ, TRI ET STATISTIQUES
# ─────────────────────────────────────────────────────────────────────────────

TC17 - Live Search Filters Table Rows
    [Documentation]    Vérifie le filtrage instantané (Live Search) dans un tableau :
    ...                La saisie de 'Laptop' dans le champ de recherche ne conserve que la ligne correspondante.
    [Tags]             advanced    table
    Go To                        ${TABLE_URL}
    Element Should Be Visible    id:table-row-1
    Input Text                   id:live-search    Laptop
    Sleep                        0.5s
    Element Should Be Visible    id:table-row-1
    Element Should Not Be Visible    id:table-row-2

TC18 - Table Column Is Sortable
    [Documentation]    Teste le tri d'une colonne de tableau par clic sur son en-tête (id:th-name) :
    ...                Le premier élément avant et après un second clic (tri inverse) doit être différent.
    [Tags]             advanced    table
    Go To                        ${TABLE_URL}
    Click Element                id:th-name
    Sleep                        0.3s
    ${first_after_sort}=         Get Text    xpath://tbody/tr[1]/td[2]
    Click Element                id:th-name
    Sleep                        0.3s
    ${first_after_reverse}=      Get Text    xpath://tbody/tr[1]/td[2]
    Should Not Be Equal          ${first_after_sort}    ${first_after_reverse}

TC19 - Summary Statistics Are Correct
    [Documentation]    Vérifie que les cartes de synthèse en haut du tableau affichent les bonnes métriques
    ...                en utilisant un sélecteur CSS combiné (#summary-total .stat-value).
    [Tags]             advanced    table
    Go To                        ${TABLE_URL}
    Element Should Be Visible    id:summary-total
    Element Should Be Visible    id:summary-in-stock
    Element Should Be Visible    id:summary-out-stock
    ${total}=                    Get Text    css:#summary-total .stat-value
    Should Be Equal As Numbers   ${total}    5
