# 1. Use the Alpine base image
FROM python:3.9-alpine

WORKDIR /app

# 2. OS-Level Remediation: 
# Force Alpine to download the newest security patches for musl, zlib, and openssl
RUN apk update && apk upgrade --no-cache

# 3. Application-Level Remediation:
# Upgrade core Python tools (wheel) and specific vulnerable dependencies (jaraco.context) 
# before installing your main application requirements.
RUN pip install --no-cache-dir --upgrade pip wheel jaraco.context flask

# 4. Copy your application code
COPY app.py .

# 5. Principle of Least Privilege: Run as a non-root user
RUN adduser -D myuser
USER myuser

# 6. Start the API
CMD ["python", "app.py"]