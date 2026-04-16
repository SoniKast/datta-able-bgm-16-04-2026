# --- ÉTAPE 1 : Builder ---
FROM python:3.9-alpine AS builder

WORKDIR /app

# Empêcher Python de générer des fichiers .pyc
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Installation des dépendances système nécessaires pour compiler certains packages Python
RUN apk add --no-cache gcc musl-dev linux-headers libffi-dev mariadb-dev

COPY requirements.txt .

# Installation des dépendances dans un dossier local pour les copier facilement
RUN pip install --upgrade pip && \
    pip install --user --no-cache-dir -r requirements.txt


# --- ÉTAPE 2 : Image Finale ---
FROM python:3.9-alpine

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV FLASK_APP run.py
ENV DEBUG True
# On ajoute le chemin des binaires installés dans le builder
ENV PATH=/root/.local/bin:$PATH

# Installation de curl uniquement (si vraiment nécessaire pour un healthcheck)
RUN apk add --no-cache curl mariadb-connector-c

# On récupère uniquement les packages installés dans le builder
COPY --from=builder /root/.local /root/.local

# Copie du code source
COPY . .

CMD ["gunicorn", "--config", "gunicorn-cfg.py", "run:app"]