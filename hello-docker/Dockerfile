# 1. Use the Alpine base image
FROM python:3.9-alpine

WORKDIR /app

# 2. OS-Level Remediation
RUN apk update && apk upgrade --no-cache

# 3. Application-Level Remediation
# First, upgrade pip itself
RUN pip install --no-cache-dir --upgrade pip
# Second, force-install the explicitly patched versions before app dependencies
RUN pip install --no-cache-dir --force-reinstall "wheel>=0.46.2" "jaraco.context>=6.1.0"
# Finally, install  application framework
RUN pip install --no-cache-dir flask

# 4. Copy application code
COPY app.py .

# 5. Principle of Least Privilege: Run as a non-root user
RUN adduser -D myuser
USER myuser

# 6. Start the API
CMD ["python", "app.py"]