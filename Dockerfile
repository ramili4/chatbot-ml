# Use a build argument for the model image
ARG MODEL_IMAGE=localhost:8082/docker-hosted/ml-model-bert-tiny:latest
FROM ${MODEL_IMAGE} AS model  # Use the passed model image

# Stage 2: Application Layer
FROM ubuntu:18.04
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY . /app/

# Copy model files directly from the model image
COPY --from=model /app/models /app/models

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Set entrypoint
CMD ["python3", "app.py"]
