FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin relay
USER relay

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
