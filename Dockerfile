FROM python:3.12-slim 

WORKDIR /app 

RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt 

COPY app ./app

RUN useradd --create-home --shell /bin/bash appuser
USER appuser

EXPOSE 8004

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://127.0.0.1:8004/ready',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8004"]