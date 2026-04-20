# 1. Use a minimalist "Slim" image for better security (smaller attack surface)
FROM python:3.9-slim

# 2. Set the working directory
WORKDIR /app

# 3. Install dependencies
RUN pip install flask

# 4. Copy your code into the container
COPY app.py .

# 5. Run the app
CMD ["python", "app.py"]