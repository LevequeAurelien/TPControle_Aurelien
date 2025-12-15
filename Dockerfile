# --- Stage 1 : Builder (On prépare l'environnement virtuel) ---
FROM python:3.9-slim AS builder

WORKDIR /app

# On crée un environnement virtuel dans /opt/venv
RUN python -m venv /opt/venv

# On active l'environnement virtuel pour la suite
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
# On installe les dépendances DANS l'environnement virtuel
RUN pip install -r requirements.txt


# --- Stage 2 : Run (L'image finale) ---
FROM python:3.9-slim AS runner

WORKDIR /app

# Création de l'utilisateur sécurisé
RUN adduser --disabled-password --gecos '' appuser

# On copie tout l'environnement virtuel depuis le builder
COPY --from=builder /opt/venv /opt/venv

# On active l'environnement virtuel pour l'utilisateur
# C'est LA ligne qui fait que "python" trouvera "flask"
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Copie du code source
COPY . .

# On donne les droits du dossier /app à l'utilisateur
RUN chown -R appuser:appuser /app

# On passe en mode sécurisé
USER appuser

# Lancement
CMD ["python", "app.py"]