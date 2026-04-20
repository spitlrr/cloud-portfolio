# 1. Use the Alpine base image
FROM python:3.9-alpine

WORKDIR /app

# 2. OS-Level Remediation
RUN apk update && apk upgrade --no-cache

# 3. Application-Level Remediation: Attack Surface Reduction
RUN pip install --no-cache-dir --upgrade pip

# Uninstall the vulnerable build tools entirely (Flask doesn't need them)
# The "|| true" ensures the build doesn't fail if they are already gone
RUN pip uninstall -y wheel jaraco.context setuptools || true

# Obliterate any "Ghost Metadata" left behind by the base image
RUN rm -rf /usr/local/lib/python3.9/site-packages/wheel* || true \
    && rm -rf /usr/local/lib/python3.9/site-packages/jaraco* || true

# 4. Install your application framework
RUN pip install --no-cache-dir flask

# 5. Copy your application code
COPY app.py .

# 6. Principle of Least Privilege: Run as a non-root user
RUN adduser -D myuser
USER myuser

# 7. Start the API
CMD ["python", "app.py"]