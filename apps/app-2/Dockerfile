FROM python:3.11-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p templates
COPY index.html templates/index.html

COPY app.py .

ENV PORT=8080
CMD ["sh","-c","gunicorn -w 2 -b 0.0.0.0:${PORT} app:app"]
