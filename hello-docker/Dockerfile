# Use Alpine for a much smaller security footprint
FROM python:3.9-alpine

WORKDIR /app

# Alpine uses 'apk' instead of 'apt'
RUN pip install --no-cache-dir flask

COPY app.py .

# Run as a non-root user (Advanced Security Tip!)
RUN adduser -D myuser
USER myuser

CMD ["python", "app.py"]