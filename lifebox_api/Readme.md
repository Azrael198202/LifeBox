# docker create db

docker volume create pgdata

docker run -d \
  --name lifebox-postgres \
  -e POSTGRES_USER=lifebox \
  -e POSTGRES_PASSWORD=lifebox_pass_123 \
  -e POSTGRES_DB=lifebox_db \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  postgres:16


# .env
# ======================
# Database
# ======================
DATABASE_URL=postgresql://lifebox:lifebox_pass_123@127.0.0.1:5433/lifebox_db

# ======================
# Auth / Security
# ======================
JWT_SECRET=change_me_to_a_long_random_secret
JWT_EXPIRES_MINUTES=10080

# ======================
# Google OAuth
# ======================
GOOGLE_CLIENT_ID=xxxxxxxxxxxx.apps.googleusercontent.com

# ======================
# App
# ======================
APP_ENV=dev

docker compose run --rm flyway-migrate


  # requirements
  pip install asyncpg pyjwt google-auth python-dotenv
  pip install bcrypt
  pip install "pydantic[email]"
  pip install email-validator


  git pull --rebase origin main