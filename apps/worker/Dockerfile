FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin relay
USER relay

CMD ["python", "main.py"]