# 📖 Guide & Documentation des Commandes Utiles — Robot Framework Training

> **Projet :** RobotApp — Application Web & Suites de Tests Automatisés  
> **Emplacement :** `/Users/bilelkhalfallah/Desktop/Auto tests /RobotFramework-Training`  
> **Accès rapide :** `~/Desktop/Auto tests/RobotFramework-Training` ou `~/Desktop/Auto tests/RobotFramework/RobotFramework-Training`

---

## 📑 Table des Matières

1. [Accès au projet & Environnement Virtuel](#1-accès-au-projet--environnement-virtuel)
2. [Lancement de l'Application Web](#2-lancement-de-lapplication-web)
3. [Exécution des Tests Robot Framework](#3-exécution-des-tests-robot-framework)
   - [A. La méthode simple (Script tout-en-un `run_tests.sh`)](#a-la-méthode-simple-script-tout-en-un-run_testssh)
   - [B. La méthode experte (Commandes natives `robot`)](#b-la-méthode-experte-commandes-natives-robot)
4. [Filtrage Avancé des Tests (Tags, Suites, Cas uniques)](#4-filtrage-avancé-des-tests)
5. [Options Utiles (Headless, Debug, Ré-exécution)](#5-options-utiles)
6. [Consultation & Analyse des Rapports de Tests](#6-consultation--analyse-des-rapports-de-tests)
7. [Identifiants & Comptes de Démonstration](#7-identifiants--comptes-de-démonstration)
8. [Aide-mémoire Syntaxe Robot Framework & Selenium](#8-aide-mémoire-syntaxe-robot-framework--selenium)

---

## 1. Accès au projet & Environnement Virtuel

Ouvrez votre Terminal (macOS) et placez-vous dans le dossier du projet :

```bash
cd "/Users/bilelkhalfallah/Desktop/Auto tests /RobotFramework-Training"
```

### Activer l'environnement virtuel Python (`venv`)
Toutes les dépendances (Robot Framework, SeleniumLibrary, RequestsLibrary, Flask) sont isolées dans ce dossier `venv` :

```bash
# Activation de l'environnement virtuel
source venv/bin/activate
```
*(Vous verrez `(venv)` apparaître au début de votre invite de commande).*

### Vérifier les installations
```bash
# Vérifier la version de Robot Framework (doit afficher 7.5 ou supérieur)
robot --version

# Vérifier la version de Python
python --version

# Lister les bibliothèques installées
pip list
```

### Désactiver l'environnement virtuel
Quand vous avez terminé votre session de travail :
```bash
deactivate
```

---

## 2. Lancement de l'Application Web

L'application web est développée en Python Flask et configurée pour écouter sur **`http://localhost:5001`** *(le port 5001 évite les conflits avec AirPlay sous macOS)*.

### Option A : Lancement via le script de surveillance (Recommandé)
Ce script lance Flask et vérifie automatiquement que l'API répond avant de vous donner le contrôle :

```bash
# Depuis la racine du projet :
python3 start_server.py
```
*Le terminal affiche le PID du serveur et l'URL. Appuyez sur **`Ctrl + C`** pour arrêter le serveur.*

### Option B : Lancement direct de Flask
```bash
python3 webapp/app.py
```

### Vérifier si le serveur tourne déjà
```bash
# Teste le endpoint de statut en ligne de commande
curl -s http://localhost:5001/api/status

# Vérifier quel processus utilise le port 5001
lsof -i :5001
```

### Arrêter un serveur resté en tâche de fond
```bash
pkill -f "webapp/app.py"
```

---

## 3. Exécution des Tests Robot Framework

### A. La méthode simple : Script tout-en-un `run_tests.sh`
Le script `./run_tests.sh` est un utilitaire complet. Si l'application web n'est pas allumée, **il la démarre tout seul**, exécute les tests, génère le rapport HTML et éteint le serveur temporaire !

```bash
# 1. Rendre le script exécutable (fait par défaut, mais au cas où)
chmod +x run_tests.sh

# 2. Exécuter TOUS les tests du projet (49 cas de test)
./run_tests.sh

# 3. Exécuter une suite spécifique par son numéro ou nom :
./run_tests.sh 01          # Suite 01 : Navigation & Menus
./run_tests.sh 02          # Suite 02 : Formulaires, Login & Register
./run_tests.sh 03          # Suite 03 : CRUD & Gestion des Produits
./run_tests.sh 04          # Suite 04 : API REST (sans navigateur, ultra-rapide)
./run_tests.sh 05          # Suite 05 : Éléments avancés (Modales, Tabs, Waits)

# 4. Exécuter par Tag métier :
./run_tests.sh smoke       # Tests de fumée prioritaires
./run_tests.sh api         # Tests API REST uniquement
./run_tests.sh auth        # Tests d'authentification
./run_tests.sh crud        # Tests de gestion des données

# 5. Exécuter en mode "Headless" (en arrière-plan, sans ouvrir Chrome) :
./run_tests.sh --headless
```

---

### B. La méthode experte : Commandes natives `robot`
*(Assurez-vous que le serveur web tourne sur `http://localhost:5001` et que le venv est activé avec `source venv/bin/activate`)*.

#### Exécuter toutes les suites de tests :
```bash
robot --outputdir reports tests/
```
*Explication des arguments :*
- `robot` : exécutable de Robot Framework.
- `--outputdir reports` : enregistre les logs, rapports et screenshots dans le dossier `reports/` au lieu de polluer la racine.
- `tests/` : dossier contenant l'ensemble des fichiers `.robot`.

#### Exécuter un seul fichier de test :
```bash
# Suite Navigation
robot --outputdir reports tests/01_navigation/test_navigation.robot

# Suite Formulaires
robot --outputdir reports tests/02_forms/test_forms_auth.robot

# Suite CRUD
robot --outputdir reports tests/03_crud/test_products_crud.robot

# Suite API REST
robot --outputdir reports tests/04_api/test_api.robot

# Suite Avancée
robot --outputdir reports tests/05_advanced/test_advanced.robot
```

#### Exécuter un SEUL cas de test par son intitulé :
Utilisez l'option `--test` (ou `-t`) suivie du nom exact du cas de test :
```bash
robot --test "TC01 - Verify Home Page Loads" --outputdir reports tests/01_navigation/test_navigation.robot
robot --test "TC02 - Admin Login Succeeds" --outputdir reports tests/02_forms/test_forms_auth.robot
robot --test "TC08 - Create New Product Successfully" --outputdir reports tests/03_crud/test_products_crud.robot
```

---

## 4. Filtrage Avancé des Tests (Tags)

Les tags sont définis dans chaque test avec la directive `[Tags]`. Ils permettent d'exécuter des campagnes de tests ciblées.

### Inclure des tags avec `-i` ou `--include`
```bash
# Lancer uniquement les tests "smoke" (tests rapides critiques)
robot -i smoke --outputdir reports tests/

# Lancer uniquement les tests d'API
robot -i api --outputdir reports tests/

# Lancer les tests touchant à l'authentification
robot -i auth --outputdir reports tests/
```

### Exclure des tags avec `-e` ou `--exclude`
```bash
# Lancer tous les tests SAUF les cas d'erreur / négatifs
robot -e negative --outputdir reports tests/

# Lancer tous les tests sauf les tests API
robot -e api --outputdir reports tests/
```

### Combiner des tags avec des opérateurs logiques (AND / OR / NOT)
```bash
# Tests qui ont À LA FOIS le tag smoke ET navigation :
robot -i smokeANDnavigation --outputdir reports tests/

# Tests qui ont SOIT le tag smoke, SOIT le tag api :
robot -i smokeORapi --outputdir reports tests/
```

---

## 5. Options Utiles

### Exécuter sans afficher la fenêtre du navigateur (Mode Headless)
Idéal pour travailler sans être interrompu par des fenêtres Chrome qui s'ouvrent :
```bash
robot --variable BROWSER:headlesschrome --outputdir reports tests/
```

### Surcharger l'URL du serveur cible
Si vous souhaitez tester l'application sur un autre port ou une autre machine :
```bash
robot --variable BASE_URL:http://127.0.0.1:5001 --outputdir reports tests/
```

### Niveau de journalisation détaillé (Debug)
Pour afficher toutes les étapes internes et valeurs de variables :
```bash
robot -L DEBUG --outputdir reports tests/
```

### Ré-exécuter UNIQUEMENT les tests qui ont échoué
Très utile après avoir corrigé un bug sans avoir à relancer toute la suite :
```bash
robot --rerunfailed reports/output.xml --outputdir reports tests/
```

---

## 6. Consultation & Analyse des Rapports de Tests

À chaque exécution, Robot Framework génère trois fichiers clés dans le dossier `reports/` :

| Fichier | Utilité | Comment l'ouvrir |
|---|---|---|
| **`reports/report.html`** | Rapport exécutif de synthèse avec graphiques camembert, statistiques, temps d'exécution et statut PASS/FAIL. | `open reports/report.html` |
| **`reports/log.html`** | Journal d'investigation technique détaillé pas-à-pas, avec chaque mot-clé, valeur de variable et capture d'écran en cas d'erreur. | `open reports/log.html` |
| **`reports/output.xml`** | Résultat brut au format XML machine-readable pour l'intégration continue (CI/CD Jenkins/GitLab). | Non destiné à la lecture humaine |

### Ouvrir les rapports dans votre navigateur par défaut (macOS) :
```bash
# Ouvrir la synthèse globale
open reports/report.html

# Ouvrir le journal détaillé pas-à-pas
open reports/log.html
```

---

## 7. Identifiants & Comptes de Démonstration

L'application intègre des comptes pré-configurés pour tester différents niveaux d'autorisation :

| Rôle | Nom d'utilisateur | Mot de passe | Droits dans l'application |
|---|---|---|---|
| **Administrateur** | `admin` | `Admin123!` | Accès total : Consultation, Création, Modification, Suppression de produits, Panneau admin. |
| **Utilisateur 1** | `user1` | `User123!` | Accès standard : Consultation, profil utilisateur, pas d'actions de modification. |
| **Utilisateur 2** | `user2` | `User123!` | Accès standard : Utilisateur secondaire pour tester les sessions indépendantes. |

---

## 8. Aide-mémoire Syntaxe Robot Framework & Selenium

### Structure d'un fichier `.robot`
```robotframework
*** Settings ***
Documentation     Description de la suite de tests
Library           SeleniumLibrary      # Importation de bibliothèque
Resource          ../variables.robot   # Importation de fichier externe
Suite Setup       Open Browser ...     # Exécuté 1 fois avant toute la suite
Suite Teardown    Close Browser        # Exécuté 1 fois à la fin de la suite

*** Variables ***
${NOM_VARIABLE}   Valeur               # Variable scalaire (2 espaces obligatoires !)

*** Test Cases ***
Mon Premier Cas De Test
    [Documentation]    Description du test
    [Tags]             smoke
    Go To              http://localhost:5001
    Title Should Be    Home — Robot Framework Training

*** Keywords ***
Mon Mot Clef Reutilisable
    [Arguments]        ${param1}
    Input Text         id:champ        ${param1}
```

### Mots-clés Selenium les plus fréquents

#### Navigation & Fenêtres :
- `Open Browser    ${URL}    ${BROWSER}` : Ouvre le navigateur.
- `Maximize Browser Window` : Maximise la fenêtre.
- `Go To    ${URL}` : Navigue vers une URL.
- `Go Back` : Simule le bouton Précédent.
- `Close Browser` : Ferme la session Selenium.

#### Saisie & Clics :
- `Input Text    id:username    mon_texte` : Tape du texte dans un champ.
- `Clear Element Text    id:username` : Efface le contenu d'un champ.
- `Click Button    id:submit-btn` : Clique sur un élément `<button>` ou `<input type="submit">`.
- `Click Link    id:nav-products` : Clique sur un lien hypertexte `<a>`.
- `Click Element    xpath://div[...]` : Clique sur n'importe quel élément HTML.

#### Formulaires riches :
- `Select From List By Value    id:category    Electronics` : Choisit une option dans un `<select>`.
- `Select Checkbox    id:newsletter` : Coche une case.
- `Unselect Checkbox    id:newsletter` : Décoche une case.
- `Checkbox Should Be Selected    id:newsletter` : Vérifie qu'une case est bien cochée.
- `Handle Alert    action=ACCEPT` : Clique sur "OK" dans une boîte de confirmation JavaScript (`confirm()`).

#### Attentes explicites (Indispensables pour la stabilité) :
- `Wait Until Element Is Visible    id:mon-element    timeout=10s` : Attend l'apparition d'un élément.
- `Wait Until Element Is Not Visible    id:spinner    timeout=10s` : Attend la disparition d'un loader.
- `Wait Until Page Contains    Mon Texte    timeout=10s` : Attend l'affichage d'un texte.

#### Vérifications & Assertions :
- `Title Should Be    Titre Exact`
- `Page Should Contain    Texte Présent`
- `Element Should Be Visible    id:mon-id`
- `Element Should Not Be Visible    id:mon-id`
- `${texte}=    Get Text    id:titre` : Récupère le texte affiché.
- `Should Be Equal    ${texte}    Valeur Attendue`
