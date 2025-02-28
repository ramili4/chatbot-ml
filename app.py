import gradio as gr
from transformers import pipeline
import json
import os

# Load model config
with open("config.json") as f:
    config = json.load(f)

MODEL_PATH = f"./model/{config['model_name']}"

# Load model
qa_pipeline = pipeline("question-answering", model=MODEL_PATH, tokenizer=MODEL_PATH)

# Function for chatbot
def chatbot(question, context):
    response = qa_pipeline(question=question, context=context)
    return response["answer"]

# Create UI
iface = gr.Interface(fn=chatbot, inputs=["text", "text"], outputs="text")
iface.launch(server_name="0.0.0.0", server_port=7860)
