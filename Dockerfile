FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

COPY . .

RUN mkdir -p instance \
    && mkdir -p app/static/Pictures_Users \
    && mkdir -p app/static/Pictures_Posts \
    && mkdir -p app/static/Pictures_Themes \
    && chmod -R 777 instance app/static

RUN echo "EMAIL_ADDRESS=test@example.com" > .env && \
    echo "EMAIL_PASSWORD=test123" >> .env && \
    echo "SECRET_KEY=9c8e5f3a2b1d4e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f" >> .env && \
    echo "SECURITY_PASSWORD_SALT=1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b" >> .env

ENV WERKZEUG_DEBUG_PIN=off

EXPOSE 5000

CMD ["sh", "-c", "python create_db.py && gunicorn -w 4 -b 0.0.0.0:5000 --access-logfile - --error-logfile - run:app"]