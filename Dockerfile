FROM python:3.9-slim

WORKDIR /TASK

COPY . .

RUN pip install --no-cache-dir flask prometheus_client

EXPOSE 80 8000

CMD ["python", "app.py"]
