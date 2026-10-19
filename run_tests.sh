#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# RUN_TESTS.SH — SCRIPT D'EXÉCUTION UNIFIÉ DES TESTS ROBOT FRAMEWORK
# ─────────────────────────────────────────────────────────────────────────────
# Ce script bash simplifie l'exécution des tests pour l'apprenant :
#   1. Vérifie la présence de l'environnement virtuel Python (venv).
#   2. Vérifie si l'application web tourne déjà sur le port 5001.
#      Si non, il la démarre automatiquement en tâche de fond !
#   3. Exécute la suite de tests demandée (ou tous les tests par défaut).
#   4. Enregistre les rapports HTML dans le dossier 'reports/'.
#   5. Arrête le serveur s'il l'avait démarré temporairement.
#   6. Affiche le lien direct vers le rapport de test 'reports/report.html'.
#
# EXEMPLES D'UTILISATION :
#   ./run_tests.sh                -> Exécute TOUS les tests (les 5 suites)
#   ./run_tests.sh 01             -> Exécute uniquement la Suite 01 (Navigation)
#   ./run_tests.sh 02             -> Exécute uniquement la Suite 02 (Formulaires & Login)
#   ./run_tests.sh 03             -> Exécute uniquement la Suite 03 (CRUD Produits)
#   ./run_tests.sh 04             -> Exécute uniquement la Suite 04 (API REST)
#   ./run_tests.sh 05             -> Exécute uniquement la Suite 05 (Composants avancés)
#   ./run_tests.sh smoke          -> Exécute uniquement les tests marqués avec le tag [smoke]
#   ./run_tests.sh api            -> Exécute uniquement les tests avec le tag [api]
#   ./run_tests.sh --headless     -> Exécute tous les tests en mode invisible sans ouvrir Chrome
# ─────────────────────────────────────────────────────────────────────────────

# Détection de l'emplacement du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$SCRIPT_DIR/venv"
ROBOT="$VENV/bin/robot"
TESTS_DIR="$SCRIPT_DIR/tests"
REPORTS_DIR="$SCRIPT_DIR/reports"
APP="$SCRIPT_DIR/webapp/app.py"
VENV_PYTHON="$VENV/bin/python"

# Codes de couleurs ANSI pour un affichage soigné dans le terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Pas de couleur

echo -e "${BLUE}==============================================================${NC}"
echo -e "${BLUE}🤖 ROBOT FRAMEWORK TEST RUNNER — FORMATION AUTOMATISATION${NC}"
echo -e "${BLUE}==============================================================${NC}"

# Étape 1 : Vérification de l'existence de Robot Framework dans le venv
if [ ! -f "$ROBOT" ]; then
    echo -e "${RED}❌ Robot Framework n'a pas été trouvé dans l'environnement virtuel !${NC}"
    echo -e "Pour installer l'environnement, exécutez :"
    echo -e "  python3 -m venv venv && ./venv/bin/pip install -r requirements.txt"
    exit 1
fi

# Étape 2 : Vérification du statut du serveur Flask (port 5001)
SERVER_RUNNING=false
SERVER_PID=""

if curl -4 -s http://127.0.0.1:5001/api/status > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Le serveur web Flask est déjà actif sur http://127.0.0.1:5001${NC}"
    SERVER_RUNNING=true
else
    echo -e "${YELLOW}⚡ Le serveur web n'est pas démarré. Lancement automatique...${NC}"
    # Lancement du serveur en tâche de fond avec redirection des logs
    "$VENV_PYTHON" "$APP" > /tmp/robotapp_server.log 2>&1 &
    SERVER_PID=$!

    # Attente active (jusqu'à 15 secondes) que le serveur réponde
    for i in {1..15}; do
        if curl -4 -s http://127.0.0.1:5001/api/status > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Serveur Flask démarré avec succès sur http://127.0.0.1:5001 (PID: $SERVER_PID)${NC}"
            SERVER_RUNNING=true
            break
        fi
        sleep 1
    done

    # Si le serveur n'a pas démarré après 15 secondes
    if [ "$SERVER_RUNNING" = false ]; then
        echo -e "${RED}❌ Impossible de démarrer le serveur Flask. Consultez /tmp/robotapp_server.log${NC}"
        exit 1
    fi
fi

echo ""
# Création du dossier reports/ s'il n'existe pas encore
mkdir -p "$REPORTS_DIR"

# Étape 3 : Construction dynamique des arguments pour la commande 'robot'
ROBOT_ARGS=("--outputdir" "$REPORTS_DIR" "--loglevel" "INFO")

# Analyse des paramètres transmis par l'utilisateur
if [ -n "$1" ]; then
    case "$1" in
        "01"|"navigation")
            echo -e "${CYAN}▶ Exécution ciblée : Suite 01 (Navigation)${NC}"
            ROBOT_ARGS+=("$TESTS_DIR/01_navigation")
            ;;
        "02"|"forms")
            echo -e "${CYAN}▶ Exécution ciblée : Suite 02 (Formulaires & Authentification)${NC}"
            ROBOT_ARGS+=("$TESTS_DIR/02_forms")
            ;;
        "03"|"crud")
            echo -e "${CYAN}▶ Exécution ciblée : Suite 03 (CRUD Produits)${NC}"
            ROBOT_ARGS+=("$TESTS_DIR/03_crud")
            ;;
        "04"|"api")
            echo -e "${CYAN}▶ Exécution ciblée : Suite 04 (API REST)${NC}"
            ROBOT_ARGS+=("$TESTS_DIR/04_api")
            ;;
        "05"|"advanced")
            echo -e "${CYAN}▶ Exécution ciblée : Suite 05 (Composants avancés)${NC}"
            ROBOT_ARGS+=("$TESTS_DIR/05_advanced")
            ;;
        "--headless")
            echo -e "${CYAN}▶ Exécution de TOUS les tests en mode HEADLESS (sans fenêtre Chrome)${NC}"
            ROBOT_ARGS+=("--variable" "BROWSER:headlesschrome" "$TESTS_DIR")
            ;;
        *)
            echo -e "${CYAN}▶ Exécution filtrée sur le tag : [$1]${NC}"
            ROBOT_ARGS+=("--include" "$1" "$TESTS_DIR")
            ;;
    esac
else
    echo -e "${CYAN}▶ Exécution de TOUTES les suites de tests du projet...${NC}"
    ROBOT_ARGS+=("$TESTS_DIR")
fi

echo -e "${BLUE}🧪 Lancement de Robot Framework...${NC}"
echo -e "📁 Dossier des rapports : $REPORTS_DIR"
echo ""

# Étape 4 : Exécution effective de Robot Framework
"$ROBOT" "${ROBOT_ARGS[@]}"
EXIT_CODE=$?

# Étape 5 : Nettoyage du serveur si nous l'avions démarré pour cette exécution
if [ -n "$SERVER_PID" ]; then
    kill "$SERVER_PID" 2>/dev/null
    echo -e "\n${YELLOW}🛑 Serveur web temporaire arrêté (PID: $SERVER_PID)${NC}"
fi

echo ""
# Étape 6 : Synthèse des résultats et affichage des liens
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}==============================================================${NC}"
    echo -e "${GREEN}✅ SUCCÈS : Tous les tests exécutés sont passés avec brio !${NC}"
    echo -e "${GREEN}==============================================================${NC}"
else
    echo -e "${RED}==============================================================${NC}"
    echo -e "${RED}❌ ÉCHEC : Certains tests ont échoué. Consultez le journal ci-dessous.${NC}"
    echo -e "${RED}==============================================================${NC}"
fi

echo -e "📄 Rapport de synthèse (HTML) : ${BLUE}file://$REPORTS_DIR/report.html${NC}"
echo -e "📋 Journal détaillé (Log)      : ${BLUE}file://$REPORTS_DIR/log.html${NC}"
echo ""
echo -e "💡 Astuce : Ouvrez le rapport directement avec la commande :"
echo -e "   open reports/report.html"
echo ""

exit $EXIT_CODE
