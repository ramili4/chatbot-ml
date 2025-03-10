# Use an official Python image
FROM python:3.9

# Set working directory
WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir gradio transformers requests

# Download model from Nexus
RUN mkdir -p /app/model && \
    wget -O /app/model/model.pth https://nexus.company.com/repository/models/model.pth

# Copy application files
COPY app.py /app/app.py

# Set entry point
CMD ["python", "app.py"]
