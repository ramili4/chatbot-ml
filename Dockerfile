# Stage 1: Extract model from the downloaded image
ARG MODEL_IMAGE
FROM ${MODEL_IMAGE} AS model-extract  # Make sure MODEL_IMAGE is properly set

# Stage 2: Application image
FROM ubuntu:18.04  # Ensure correct `FROM` syntax
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy the model from the extracted model image
COPY --from=model-extract /app/model/model.pth /app/model/model.pth

# Copy application files
COPY . /app/

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Set entrypoint
CMD ["python3", "app.py"]
