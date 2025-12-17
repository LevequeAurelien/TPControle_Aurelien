# --- Stage 1 : Builder (On prépare l'environnement virtuel) ---
FROM python:3.9-slim AS builder

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app

COPY requirements.txt .
# On installe les dépendances DANS l'environnement virtuel
RUN pip install -r requirements.txt

# Création de l'utilisateur sécurisé
RUN adduser --disabled-password --gecos '' appuser

# Copie du code source
COPY . .

# On donne les droits du dossier /app à l'utilisateur
RUN chown -R appuser:appuser /app

# On passe en mode sécurisé
USER appuser

# Lancement
CMD ["python", "app.py"]