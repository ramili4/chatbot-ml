# Use a suitable base image
FROM python:3.9-slim

# Set environment variables
ARG MODEL_IMAGE
ENV MODEL_CACHE_DIR="/app/model"

# Install necessary dependencies
RUN apt-get update && apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# Create model directory
RUN mkdir -p ${MODEL_CACHE_DIR}

# Download the model dynamically from Nexus
RUN wget -O ${MODEL_CACHE_DIR}/model.pth "${MODEL_IMAGE}"

# Copy application files (Assuming the chatbot app is in the same directory)
WORKDIR /app
COPY . /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose application port (Change as needed)
EXPOSE 7860

# Run the chatbot application
CMD ["python", "app.py"]
