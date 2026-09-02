#!/usr/bin/env bash
# ============================================================
# DJANGO + DRF ZERO-TO-RUNNING CHEAT SHEET
# Copy-paste friendly. Adjust names in ALL_CAPS placeholders.
# ============================================================

# ------------------------------------------------------------
# 1. VIRTUAL ENVIRONMENT
# ------------------------------------------------------------
# Linux / macOS
python3 -m venv venv
source venv/bin/activate

# Windows (cmd)
python -m venv venv
venv\Scripts\activate.bat

# Windows (PowerShell)
python -m venv venv
venv\Scripts\Activate.ps1

# Deactivate (any OS)
deactivate

# ------------------------------------------------------------
# 2. INSTALL CORE PACKAGES
# ------------------------------------------------------------
pip install --upgrade pip

pip install \
  django \
  djangorestframework \
  djangorestframework-simplejwt \
  psycopg2-binary \
  python-decouple \
  django-cors-headers \
  django-filter

# Optional, if the task needs async tasks
pip install celery redis

# Freeze once everything works
pip freeze > requirements.txt

# ------------------------------------------------------------
# 3. START PROJECT / APP
# ------------------------------------------------------------
# Project (note the trailing dot = create in current dir, no extra nesting)
django-admin startproject config .

# App
python manage.py startapp core

# ------------------------------------------------------------
# 4. DATABASE — POSTGRES CONNECTION STRING FORMATS
# ------------------------------------------------------------
# Standard URL form (used by dj-database-url style configs):
# postgres://USER:PASSWORD@HOST:PORT/DBNAME
#
# Example (local default):
# postgres://postgres:postgres@localhost:5432/mydb
#
# In .env (see .env.example) — split form used by settings.py below:
# DB_NAME=mydb
# DB_USER=postgres
# DB_PASSWORD=postgres
# DB_HOST=localhost
# DB_PORT=5432

# Quick local Postgres via Docker (if Docker is available and Postgres isn't installed)
docker run --name pg-dev -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=mydb -p 5432:5432 -d postgres:16

# Create DB manually (if Postgres is installed locally, not via Docker)
psql -U postgres -c "CREATE DATABASE mydb;"

# FALLBACK: if Postgres setup stalls, switch settings.py DATABASES to sqlite3
# and keep moving — swap back once Postgres is confirmed working.

# ------------------------------------------------------------
# 5. MIGRATIONS
# ------------------------------------------------------------
python manage.py makemigrations
python manage.py migrate

# Custom (empty) migration for data migrations
python manage.py makemigrations core --empty --name backfill_something

# ------------------------------------------------------------
# 6. SUPERUSER + RUN
# ------------------------------------------------------------
python manage.py createsuperuser
python manage.py runserver
# -> http://127.0.0.1:8000/
# -> Admin: http://127.0.0.1:8000/admin/
# -> DRF browsable API: http://127.0.0.1:8000/api/

# ------------------------------------------------------------
# 7. JWT QUICK TEST (after urls wired — see boilerplate)
# ------------------------------------------------------------
# Get token pair
curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "USERNAME", "password": "PASSWORD"}'

# Use token
curl http://127.0.0.1:8000/api/some-endpoint/ \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Refresh token
curl -X POST http://127.0.0.1:8000/api/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{"refresh": "REFRESH_TOKEN_HERE"}'

# ------------------------------------------------------------
# 8. CELERY QUICK START (only if task needs async)
# ------------------------------------------------------------
# Run redis (Docker fallback if not installed locally)
docker run --name redis-dev -p 6379:6379 -d redis:7

# Run worker (separate terminal, from project root, venv active)
celery -A config worker -l info

# ------------------------------------------------------------
# 9. GIT DISCIPLINE — COMMIT AT CHECKPOINTS
# ------------------------------------------------------------
git init
git add .
git commit -m "chore: project scaffold + settings"
# ... after models ...
git commit -am "feat: models + migrations"
# ... after serializers/views ...
git commit -am "feat: serializers + views + urls"
# ... after validation/testing ...
git commit -am "feat: validation + error handling"
