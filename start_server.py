#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
==============================================================================
SCRIPT DE DÉMARRAGE DU SERVEUR WEB FLASK (start_server.py)
==============================================================================
Ce script Python permet de lancer l'application web RobotApp en arrière-plan
et de s'assurer qu'elle répond correctement avant de rendre la main.

Fonctionnement :
  1. Identifie l'exécutable Python de l'environnement virtuel (venv).
  2. Lance 'webapp/app.py' dans un sous-processus dédié.
  3. Effectue un sondage (polling HTTP) vers http://localhost:5001/api/status
     jusqu'à ce que le serveur réponde HTTP 200 OK (ou timeout de 15 secondes).
  4. Maintient le serveur actif et intercepte Ctrl+C pour une extinction propre.

Utilisation :
  python3 start_server.py
  (ou ./venv/bin/python start_server.py)
==============================================================================
"""

import subprocess
import sys
import time
import urllib.request
import os
import signal

# Détermination dynamique des chemins absolus vers le venv et l'application
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
VENV_PYTHON = os.path.join(SCRIPT_DIR, "venv", "bin", "python")
APP_PATH = os.path.join(SCRIPT_DIR, "webapp", "app.py")

# URL de test de disponibilité (port 5001 utilisé pour éviter les conflits macOS AirPlay sur le port 5000)
STATUS_URL = "http://localhost:5001/api/status"


def wait_for_server(timeout=15):
    """
    Attend que le serveur Flask réponde sur son endpoint de santé /api/status.
    Effectue des requêtes répétées toutes les secondes.
    Retourne True si le serveur est opérationnel, False si le délai est dépassé.
    """
    print("⏳ Attente de la disponibilité du serveur Flask sur http://localhost:5001...")
    for i in range(timeout):
        try:
            with urllib.request.urlopen(STATUS_URL, timeout=2) as response:
                if response.status == 200:
                    print(f"✅ Serveur opérationnel sur http://localhost:5001 (réponse en {i+1}s)")
                    return True
        except Exception:
            # Le serveur est encore en train de démarrer
            time.sleep(1)
            print(f"   ... tentative {i+1}/{timeout}")
    return False


def main():
    """Point d'entrée principal pour démarrer Flask."""
    # Vérification de l'existence du python du venv, sinon repli sur le python courant
    python_bin = VENV_PYTHON if os.path.isfile(VENV_PYTHON) else sys.executable

    print("=" * 60)
    print("🤖 DÉMARRAGE DE L'APPLICATION WEB ROBOT FRAMEWORK")
    print("=" * 60)
    print(f"▶ Interpréteur Python : {python_bin}")
    print(f"▶ Fichier application : {APP_PATH}")

    # Préparation des variables d'environnement
    env = os.environ.copy()
    env["FLASK_ENV"] = "development"

    # Lancement du processus Flask
    proc = subprocess.Popen(
        [python_bin, APP_PATH],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    # Attente que le serveur soit prêt à recevoir des requêtes HTTP
    if not wait_for_server():
        print("❌ Échec du démarrage du serveur Flask ! Vérifiez les logs ou si le port 5001 est occupé.")
        proc.terminate()
        sys.exit(1)

    print("\n" + "─" * 60)
    print(f"🎉 Serveur Flask actif ! (Process ID / PID : {proc.pid})")
    print("👉 Accédez à l'application dans votre navigateur : http://localhost:5001")
    print("👉 Appuyez sur Ctrl + C pour arrêter le serveur à tout moment.")
    print("─" * 60 + "\n")

    # Attente de l'interruption utilisateur (Ctrl+C)
    try:
        proc.wait()
    except KeyboardInterrupt:
        print("\n🛑 Arrêt propre du serveur en cours...")
        proc.terminate()
        proc.wait(timeout=5)
        print("✅ Serveur arrêté avec succès.")


if __name__ == "__main__":
    main()
