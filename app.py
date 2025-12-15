import os
import time
from flask import Flask, render_template, request, redirect
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import OperationalError

app = Flask(__name__)

# Configuration BDD
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DB_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)


class Compteur(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    valeur = db.Column(db.Integer, default=0)


# --- Fonction d'initialisation avec RETRY ---
def init_db():
    print("Tentative de connexion à la BDD...")
    with app.app_context():
        # On essaie 10 fois maximum
        for i in range(10):
            try:
                db.create_all()
                if not Compteur.query.first():
                    db.session.add(Compteur(valeur=0))
                    db.session.commit()
                print(">>> Connexion BDD réussie !")
                return  # On sort de la fonction si ça marche
            except OperationalError:
                print(f"La BDD n'est pas prête... nouvel essai dans 2s ({i + 1}/10)")
                time.sleep(2)

        print(">>> Abandon : Impossible de se connecter à la BDD.")


# --- Routes ---
@app.route('/', methods=['GET', 'POST'])
def index():
    compteur = Compteur.query.first()

    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'increment':
            compteur.valeur += 1
        elif action == 'decrement':
            compteur.valeur -= 1
        db.session.commit()
        return redirect('/')

    return render_template('index.html', nombre=compteur.valeur)


if __name__ == '__main__':
    # On lance l'attente de la BDD avant de lancer le serveur
    init_db()
    app.run(host='0.0.0.0', port=8080)