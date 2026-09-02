# Django + DRF Practical-Round Boilerplate

Pre-built scaffold for timed practical rounds: DRF + JWT wired up, env-based
Postgres config with a SQLite fallback, and a worked nested-serializer
example (`Order` → `OrderItem`) demonstrating multi-table create/update with
validation — the exact pattern usually asked about in interviews.

## Quick start

```bash
# 1. Create + activate venv
python3 -m venv venv
source venv/bin/activate        # venv\Scripts\activate.bat on Windows cmd

# 2. Install deps
pip install -r requirements.txt

# 3. Configure env
cp .env.example .env
# edit .env — set DB_ENGINE=sqlite for an instant fallback if Postgres
# setup is slow, or fill in DB_* vars for real Postgres

# 4. Migrate + create admin user
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser

# 5. Run
python manage.py runserver
```

- Admin: http://127.0.0.1:8000/admin/
- API root: http://127.0.0.1:8000/api/orders/
- JWT: `POST /api/token/`, `POST /api/token/refresh/`

See `CHEATSHEET.sh` for copy-paste commands (venv, installs, Postgres/Docker,
migrations, JWT curl tests, Celery quick start, git checkpoint commits).

## What's included

- `config/settings.py` — DRF + SimpleJWT configured, env-driven DB switch
  (Postgres ⇄ SQLite), CORS, pagination, filtering.
- `core/models.py` — sample parent/child models (`Order`, `OrderItem`).
- `core/serializers.py` — nested serializer with `validate()`,
  `transaction.atomic()` create/update across both tables, and a comment
  explaining the merge-vs-replace strategy for partial nested updates.
- `core/views.py` — plain `ModelViewSet`; no create/update override needed
  since the logic lives in the serializer.
- `.env.example` — copy to `.env` before running.

## Adapting to a live task

Rename `Order`/`OrderItem` to whatever domain you're given (e.g.
`Author`/`Book`, `Patient`/`Appointment`) — the nested-write pattern in
`serializers.py` stays the same. Swap the model, fields, and validation
rules; keep the structure.
