import gradio as gr
from transformers import pipeline
import os

# Model path inside the container
MODEL_PATH = "./model"

# Ensure the model directory exists
if not os.path.exists(MODEL_PATH):
    os.makedirs(MODEL_PATH)

# Load model
qa_pipeline = pipeline("question-answering", model=MODEL_PATH, tokenizer=MODEL_PATH)

# Function for chatbot
def chatbot(question, context):
    response = qa_pipeline(question=question, context=context)
    return response["answer"]

# Create Gradio UI
iface = gr.Interface(fn=chatbot, inputs=["text", "text"], outputs="text")
iface.launch(server_name="0.0.0.0", server_port=7860)
