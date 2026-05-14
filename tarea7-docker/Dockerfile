# Tarea 7 - Docker | Alumno: JJLR | UAX DevOps 2026
FROM python:3.11-slim

LABEL maintainer="JJLR"       description="DevOps UAX Tarea 7 - Flask Hello World"       version="1.0.0"

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir flask==3.0.0

# Copy application
COPY app.py .

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Run application
CMD ["python", "app.py"]
