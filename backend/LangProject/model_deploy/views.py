import torchaudio
import torch
import tempfile
import numpy as np
from pydub import AudioSegment
import tempfile
import os
import json
from pathlib import Path
from transformers import Wav2Vec2Processor, Wav2Vec2ForSequenceClassification

from rest_framework.response import Response
from rest_framework.decorators import api_view

# Base Directory
BASE_DIR = Path(__file__).resolve().parent.parent

config_path = os.path.join(BASE_DIR, "config.json")
if os.path.exists(config_path):
    with open(config_path) as config_file:
        config_data = json.load(config_file)
else:
    config_data = {}


MODEL_PATH = config_data.get("Model_Path")
processor = Wav2Vec2Processor.from_pretrained(MODEL_PATH)
model = Wav2Vec2ForSequenceClassification.from_pretrained(MODEL_PATH)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)
model.eval()

# Define max_length (in terms of audio frames)
MAX_LENGTH = 32000  # Adjust if needed

# Target labels (Numbers 0-9)
TARGET_LABELS = {'Eight': 0, 'Five': 1, 'Four': 2, 'Nine': 3, 'One': 4, 'Seven': 5, 'Six': 6, 'Three': 7, 'Two': 8, 'Zero': 9,
                 'अ': 10, 'अं': 11, 'अः': 12, 'आ': 13, 'इ': 14, 'ई': 15, 'उ': 16, 'ऊ': 17,
                 'ए': 18, 'ऐ': 19, 'ओ': 20, 'औ': 21, 'क': 22, 'ख': 23, 'ग': 24, 'घ': 25, 'ङ': 26}

# Reverse the mapping to get index -> label
index_to_label = {v: k for k, v in TARGET_LABELS.items()}

def predict_audio(audio_path):
    print(f"Loading audio: {audio_path}")

    waveform, sample_rate = torchaudio.load(audio_path)
    print(f"Sample rate: {sample_rate}, Shape: {waveform.shape}")

    # Convert stereo to mono
    if waveform.shape[0] > 1:
        print("Converting to mono....")
        waveform = waveform.mean(dim=0)

    # Resample to 16kHz
    if sample_rate != 16000:
        print("Resampling to 16kHz...")
        resampler = torchaudio.transforms.Resample(orig_freq=sample_rate, new_freq=16000)
        waveform = resampler(waveform)

    print(f"Processed waveform shape: {waveform.shape}")

    # Convert to tensor and pass through processor
    waveform = waveform.numpy().flatten().tolist()
    input_values = processor(
        waveform, return_tensors="pt", sampling_rate=16000,
        truncation=True, padding="max_length", max_length=MAX_LENGTH
    ).input_values

    print("Running model inference.....")
    with torch.no_grad():
        outputs = model(input_values)

    logits = outputs.logits
    predicted_id = torch.argmax(logits, dim=-1).item()
    print(f"Model output: {predicted_id}")

    predicted_label = index_to_label.get(predicted_id, "Unknown Label")
    print(f"Predicted Label: {predicted_label}")

    return predicted_label




@api_view(["POST"])
def evaluate_speech(request):
    print("🔹 API endpoint hit!")  # Debugging

    file = request.FILES.get("file")
    expected_label = request.POST.get("label")  

    # Debug: print file and expected letter
    print(f"Received file: {file}")
    print(f"Expected label: {expected_label}")

    if not file or expected_label not in TARGET_LABELS:
        return Response({"error": "Invalid input"}, status=400)

    print("Checkpoint 1: File received successfully.")

    # Save the received AAC file in a temp directory
    with tempfile.NamedTemporaryFile(delete=False, suffix=".aac") as temp_audio:
        for chunk in file.chunks():
            temp_audio.write(chunk)
        temp_audio_path = temp_audio.name

    print(f"File saved at: {temp_audio_path}")

    # Verify file content
    import os
    print(f"File size: {os.path.getsize(temp_audio_path)} bytes")

    # Convert AAC to WAV using pydub
    try:
        print("Converting AAC to WAV...")
        audio = AudioSegment.from_file(temp_audio_path, format="aac")
        wav_temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
        audio.export(wav_temp_file.name, format="wav")
        wav_temp_file_path = wav_temp_file.name
        print(f"Converted to WAV at: {wav_temp_file_path}")
    except Exception as e:
        print(f"Audio conversion failed: {e}")
        return Response({"error": f"Error converting audio file: {str(e)}"}, status=500)

    print("Checkpoint 2: Audio conversion successful.")

    # Predict letter from the WAV file
    print("Calling predict_audio_asr()...")
    predicted_label = predict_audio(wav_temp_file_path)

    if predicted_label is None:
        return Response({"error": "Failed to process audio"}, status=500)

    print("Checkpoint 3: Prediction successful.")

    # Compute accuracy (Simple match-based)
    accuracy = 100 if predicted_label == expected_label else 0

    # Cleanup temporary files
    try:
        os.remove(temp_audio_path)
        os.remove(wav_temp_file_path)
    except Exception as e:
        print(f"Error deleting temp files: {e}")

    return Response({
        "predicted_label": predicted_label,
        "expected_label": expected_label,
        "accuracy": accuracy
    })
