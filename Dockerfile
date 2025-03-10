# Stage 1: Application image
FROM ubuntu:18.04  

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Define build arguments
ARG MODEL_CACHE_DIR
ARG MODEL_NAME

# Ensure the model directory exists and copy the correct model
RUN mkdir -p /app/models/${MODEL_NAME}
COPY ${MODEL_CACHE_DIR}/model.pth /app/models/${MODEL_NAME}/pytorch_model.bin

# Copy application files
COPY . /app/

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Set entrypoint
CMD ["python3", "app.py"]
