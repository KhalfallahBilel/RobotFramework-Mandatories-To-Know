# -*- coding: utf-8 -*-
"""
==============================================================================
APPLICATION WEB ROBOTAPP — SERVEUR FLASK (webapp/app.py)
==============================================================================
Cette application Flask sert de cible d'entraînement ("SUT" - System Under Test)
pour pratiquer l'automatisation de tests avec Robot Framework et Selenium.

Elle intègre :
  - Un système d'authentification complet (Login, Register, Logout, rôles Admin/User).
  - Un catalogue de produits avec cycle CRUD (Consultation, Ajout, Édition, Suppression).
  - Un formulaire de contact riche (inputs, dropdown, radios, checkboxes).
  - Une page de composants avancés (modales, onglets, accordéons).
  - Une page de contenus dynamiques (délais AJAX, spinners, pagination, live search).
  - Une API REST complète (/api/products, /api/status, /api/contacts).

Port d'écoute : 5001 (127.0.0.1:5001)
==============================================================================
"""

from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash
from functools import wraps
import json
import os
import uuid
from datetime import datetime

# Initialisation de l'application Flask
app = Flask(__name__)

# Clé secrète requise par Flask pour signer les cookies de session
app.secret_key = "robotframework-training-secret-key-2024"

# ─────────────────────────────────────────────────────────────────────────────
# 1. BASE DE DONNÉES EN MÉMOIRE (SIMULATION)
# ─────────────────────────────────────────────────────────────────────────────
# Comptes utilisateurs pré-configurés pour les tests d'authentification
users_db = {
    "admin": {"password": "Admin123!", "role": "admin", "name": "Admin User", "email": "admin@testapp.local"},
    "user1": {"password": "User123!", "role": "user", "name": "Alice Martin", "email": "alice@testapp.local"},
    "user2": {"password": "User123!", "role": "user", "name": "Bob Dupont", "email": "bob@testapp.local"},
}

# Catalogue initial de produits pour les tests CRUD et la recherche
products_db = [
    {"id": "1", "name": "Laptop Pro 15", "category": "Electronics", "price": 1299.99, "stock": 42, "description": "Powerful laptop for professionals"},
    {"id": "2", "name": "Wireless Mouse", "category": "Accessories", "price": 29.99, "stock": 150, "description": "Ergonomic wireless mouse"},
    {"id": "3", "name": "Mechanical Keyboard", "category": "Accessories", "price": 89.99, "stock": 75, "description": "RGB mechanical keyboard"},
    {"id": "4", "name": "4K Monitor", "category": "Electronics", "price": 499.99, "stock": 20, "description": "27-inch 4K display"},
    {"id": "5", "name": "USB-C Hub", "category": "Accessories", "price": 49.99, "stock": 0, "description": "7-in-1 USB-C hub"},
]

# Stockage des messages envoyés via le formulaire de contact
contacts_db = []
# Stockage des commandes passées
orders_db = []

# ─────────────────────────────────────────────────────────────────────────────
# 2. DÉCORATEURS DE SÉCURITÉ & CONTRÔLE D'ACCÈS
# ─────────────────────────────────────────────────────────────────────────────

def login_required(f):
    """
    Décorateur vérifiant que l'utilisateur est authentifié en session.
    Redirige automatiquement vers la page de login si non connecté.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        if "username" not in session:
            return redirect(url_for("login", next=request.url))
        return f(*args, **kwargs)
    return decorated


def admin_required(f):
    """
    Décorateur restreignant l'accès aux utilisateurs ayant le rôle 'admin'.
    Affiche un message flash d'erreur et renvoie au dashboard si l'accès est refusé.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        if "username" not in session:
            return redirect(url_for("login"))
        if users_db.get(session["username"], {}).get("role") != "admin":
            flash("Access denied. Admin only.", "danger")
            return redirect(url_for("dashboard"))
        return f(*args, **kwargs)
    return decorated

# ─────────────────────────────────────────────────────────────────────────────
# 3. ROUTES DES PAGES WEB (RENDU HTML)
# ─────────────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    """Page d'accueil : Présente le projet, les cartes d'accès rapide et la liste des endpoints API."""
    return render_template("index.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    """
    Page de connexion :
    - GET  : Affiche le formulaire de login.
    - POST : Valide les identifiants contre users_db et initialise la session.
    """
    error = None
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        password = request.form.get("password", "")
        user = users_db.get(username)
        if user and user["password"] == password:
            session["username"] = username
            session["role"] = user["role"]
            session["name"] = user["name"]
            flash(f"Welcome back, {user['name']}!", "success")
            return redirect(url_for("dashboard"))
        else:
            error = "Invalid username or password."
    return render_template("login.html", error=error)


@app.route("/logout")
def logout():
    """Déconnexion : Détruit la session active et redirige vers l'accueil."""
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for("index"))


@app.route("/register", methods=["GET", "POST"])
def register():
    """
    Page d'inscription :
    Valide les règles métier (longueur du login, doublons, format email, confirmation du mot de passe).
    """
    errors = {}
    if request.method == "POST":
        username = request.form.get("username", "").strip()
        email = request.form.get("email", "").strip()
        name = request.form.get("name", "").strip()
        password = request.form.get("password", "")
        confirm = request.form.get("confirm_password", "")

        # Règles de validation
        if not username or len(username) < 3:
            errors["username"] = "Username must be at least 3 characters."
        elif username in users_db:
            errors["username"] = "Username already taken."
        if not email or "@" not in email:
            errors["email"] = "Please enter a valid email address."
        if not name:
            errors["name"] = "Full name is required."
        if not password or len(password) < 6:
            errors["password"] = "Password must be at least 6 characters."
        if password != confirm:
            errors["confirm_password"] = "Passwords do not match."

        # Si aucune erreur, enregistrement dans la base
        if not errors:
            users_db[username] = {"password": password, "role": "user", "name": name, "email": email}
            flash("Account created! Please log in.", "success")
            return redirect(url_for("login"))
    return render_template("register.html", errors=errors)


@app.route("/dashboard")
@login_required
def dashboard():
    """Tableau de bord sécurisé : Accessible uniquement aux utilisateurs connectés."""
    stats = {
        "products": len(products_db),
        "contacts": len(contacts_db),
        "orders": len(orders_db),
        "users": len(users_db),
    }
    return render_template("dashboard.html", stats=stats)


@app.route("/products")
def products():
    """Catalogue de produits : Supporte le filtrage par catégorie et la recherche textuelle."""
    category_filter = request.args.get("category", "")
    search = request.args.get("search", "").lower()
    filtered = products_db
    if category_filter:
        filtered = [p for p in filtered if p["category"] == category_filter]
    if search:
        filtered = [p for p in filtered if search in p["name"].lower() or search in p["description"].lower()]
    categories = list(set(p["category"] for p in products_db))
    return render_template("products.html", products=filtered, categories=categories,
                           category_filter=category_filter, search=search)


@app.route("/products/<product_id>")
def product_detail(product_id):
    """Fiche détaillée d'un produit avec fil d'Ariane."""
    product = next((p for p in products_db if p["id"] == product_id), None)
    if not product:
        flash("Product not found.", "warning")
        return redirect(url_for("products"))
    return render_template("product_detail.html", product=product)


@app.route("/products/new", methods=["GET", "POST"])
@login_required
@admin_required
def product_new():
    """Formulaire de création de produit (réservé aux administrateurs)."""
    errors = {}
    if request.method == "POST":
        name = request.form.get("name", "").strip()
        category = request.form.get("category", "").strip()
        price = request.form.get("price", "")
        stock = request.form.get("stock", "")
        description = request.form.get("description", "").strip()

        if not name:
            errors["name"] = "Product name is required."
        if not category:
            errors["category"] = "Category is required."
        try:
            price = float(price)
            if price < 0:
                errors["price"] = "Price must be positive."
        except:
            errors["price"] = "Invalid price."
        try:
            stock = int(stock)
            if stock < 0:
                errors["stock"] = "Stock must be >= 0."
        except:
            errors["stock"] = "Invalid stock quantity."

        if not errors:
            new_id = str(max(int(p["id"]) for p in products_db) + 1)
            products_db.append({"id": new_id, "name": name, "category": category,
                                 "price": price, "stock": stock, "description": description})
            flash(f"Product '{name}' created successfully!", "success")
            return redirect(url_for("products"))
    return render_template("product_form.html", product=None, errors=errors, action="Create")


@app.route("/products/<product_id>/edit", methods=["GET", "POST"])
@login_required
@admin_required
def product_edit(product_id):
    """Formulaire de modification de produit (réservé aux administrateurs)."""
    product = next((p for p in products_db if p["id"] == product_id), None)
    if not product:
        flash("Product not found.", "warning")
        return redirect(url_for("products"))
    errors = {}
    if request.method == "POST":
        product["name"] = request.form.get("name", "").strip()
        product["category"] = request.form.get("category", "").strip()
        try:
            product["price"] = float(request.form.get("price", 0))
        except:
            errors["price"] = "Invalid price."
        try:
            product["stock"] = int(request.form.get("stock", 0))
        except:
            errors["stock"] = "Invalid stock."
        product["description"] = request.form.get("description", "").strip()
        if not errors:
            flash(f"Product updated!", "success")
            return redirect(url_for("products"))
    return render_template("product_form.html", product=product, errors=errors, action="Edit")


@app.route("/products/<product_id>/delete", methods=["POST"])
@login_required
@admin_required
def product_delete(product_id):
    """Suppression d'un produit (réservé aux administrateurs)."""
    global products_db
    products_db = [p for p in products_db if p["id"] != product_id]
    flash("Product deleted successfully.", "success")
    return redirect(url_for("products"))


@app.route("/contact", methods=["GET", "POST"])
def contact():
    """Formulaire de contact riche : text, select, radio buttons, checkbox."""
    errors = {}
    submitted = False
    if request.method == "POST":
        first_name = request.form.get("first_name", "").strip()
        last_name = request.form.get("last_name", "").strip()
        email = request.form.get("email", "").strip()
        subject = request.form.get("subject", "").strip()
        message = request.form.get("message", "").strip()
        rating = request.form.get("rating", "5")
        newsletter = request.form.get("newsletter") == "on"

        if not first_name: errors["first_name"] = "First name is required."
        if not last_name: errors["last_name"] = "Last name is required."
        if not email or "@" not in email: errors["email"] = "Valid email is required."
        if not subject: errors["subject"] = "Please select a subject."
        if not message or len(message) < 10: errors["message"] = "Message must be at least 10 characters."

        if not errors:
            contacts_db.append({
                "id": str(uuid.uuid4())[:8],
                "first_name": first_name,
                "last_name": last_name,
                "email": email,
                "subject": subject,
                "message": message,
                "rating": rating,
                "newsletter": newsletter,
                "created_at": datetime.now().strftime("%Y-%m-%d %H:%M"),
            })
            submitted = True
    return render_template("contact.html", errors=errors, submitted=submitted)


@app.route("/about")
def about():
    """Page d'information et de présentation de l'équipe."""
    team = [
        {"name": "Sarah Connor", "role": "Lead QA Engineer", "avatar": "👩‍💻"},
        {"name": "Alex Murphy", "role": "Automation Architect", "avatar": "🤖"},
        {"name": "John Matrix", "role": "DevOps & CI/CD", "avatar": "🚀"},
    ]
    return render_template("about.html", team=team)


@app.route("/table")
def table():
    """Tableau de données avec recherche dynamique en direct et tri."""
    return render_template("table.html", products=products_db)


@app.route("/alerts")
def alerts():
    """Page de démonstration des modales, onglets (tabs), et accordéons."""
    return render_template("alerts.html")


@app.route("/dynamic")
def dynamic():
    """Page de démonstration des éléments asynchrones, spinners et pagination."""
    return render_template("dynamic.html")

# ─────────────────────────────────────────────────────────────────────────────
# 4. ENDPOINTS DE L'API REST (JSON)
# ─────────────────────────────────────────────────────────────────────────────

@app.route("/api/products", methods=["GET"])
def api_products():
    """API GET : Liste tous les produits au format JSON (HTTP 200)."""
    return jsonify(products_db)


@app.route("/api/products/<product_id>", methods=["GET"])
def api_product(product_id):
    """API GET : Retourne un produit spécifique ou 404 Not Found."""
    product = next((p for p in products_db if p["id"] == product_id), None)
    if not product:
        return jsonify({"error": "Not found"}), 404
    return jsonify(product)


@app.route("/api/products", methods=["POST"])
def api_create_product():
    """API POST : Crée un produit depuis un payload JSON (HTTP 201 Created)."""
    data = request.get_json()
    if not data or not data.get("name"):
        return jsonify({"error": "Name is required"}), 400
    new_id = str(max(int(p["id"]) for p in products_db) + 1)
    product = {
        "id": new_id,
        "name": data.get("name"),
        "category": data.get("category", "General"),
        "price": float(data.get("price", 0)),
        "stock": int(data.get("stock", 0)),
        "description": data.get("description", ""),
    }
    products_db.append(product)
    return jsonify(product), 201


@app.route("/api/products/<product_id>", methods=["PUT"])
def api_update_product(product_id):
    """API PUT : Met à jour un produit existant (HTTP 200 OK ou 404)."""
    product = next((p for p in products_db if p["id"] == product_id), None)
    if not product:
        return jsonify({"error": "Not found"}), 404
    data = request.get_json()
    product.update({k: v for k, v in data.items() if k != "id"})
    return jsonify(product)


@app.route("/api/products/<product_id>", methods=["DELETE"])
def api_delete_product(product_id):
    """API DELETE : Supprime un produit par son identifiant (HTTP 200 ou 404)."""
    global products_db
    before = len(products_db)
    products_db = [p for p in products_db if p["id"] != product_id]
    if len(products_db) == before:
        return jsonify({"error": "Not found"}), 404
    return jsonify({"message": "Deleted"})


@app.route("/api/contacts", methods=["GET"])
def api_contacts():
    """API GET : Liste des messages de contact reçus."""
    return jsonify(contacts_db)


@app.route("/api/status", methods=["GET"])
def api_status():
    """API GET : Endpoint de santé et monitoring utilisé pour vérifier la disponibilité de l'application."""
    return jsonify({"status": "ok", "timestamp": datetime.now().isoformat(), "version": "1.0.0"})


@app.route("/api/users/me", methods=["GET"])
def api_me():
    """API GET : Retourne les informations du profil utilisateur connecté (HTTP 401 si non authentifié)."""
    if "username" not in session:
        return jsonify({"error": "Not authenticated"}), 401
    user = users_db[session["username"]].copy()
    user.pop("password")
    user["username"] = session["username"]
    return jsonify(user)

# ─────────────────────────────────────────────────────────────────────────────
# 5. DÉMARRAGE DU SERVEUR
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # Écoute sur l'interface locale 127.0.0.1 et le port 5001
    app.run(host="127.0.0.1", port=5001, debug=True)
