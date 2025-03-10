# Stage 1: Application image
FROM ubuntu:18.04  # Ensure correct `FROM` syntax
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy the model from the build context
ARG MODEL_CACHE_DIR
COPY ${MODEL_CACHE_DIR}/model.pth /app/model/model.pth

# Copy application files
COPY . /app/

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Set entrypoint
CMD ["python3", "app.py"]
