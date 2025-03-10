# Define the model image argument
ARG MODEL_IMAGE=localhost:8082/docker-hosted/ml-model-bert-tiny:latest

# Use an explicit stage name for clarity
FROM ${MODEL_IMAGE} AS model

# Stage 2: Application Layer
FROM ubuntu:20.04

WORKDIR /app

# Install dependencies and avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-setuptools build-essential libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip before installing packages
RUN pip3 install --upgrade pip setuptools wheel

# Copy application files
COPY . /app/

# Ensure the models directory exists before copying
RUN mkdir -p /app/models

# Copy model files directly from the model image
COPY --from=model /app/models /app/models

# Debug: List model files to verify they were copied correctly
RUN ls -la /app/models

# Install Python dependencies with explicit torch installation
RUN pip3 install --no-cache-dir torch transformers gradio
RUN pip3 install --no-cache-dir -r requirements.txt

# Expose the Gradio server port
EXPOSE 7860

# Set entrypoint
CMD ["python3", "app.py"]
