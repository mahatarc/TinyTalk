import torchaudio
import torch
import tempfile
import numpy as np
from pydub import AudioSegment
import tempfile
import os

from transformers import Wav2Vec2Processor, Wav2Vec2ForSequenceClassification

from rest_framework.response import Response
from rest_framework.decorators import api_view

# Load fine-tuned model (Ensure correct path)
MODEL_PATH = os.path.expanduser("~/Documents/Tiny Talk/TinyTalk/fine_tuned_model/fine_tuned_model")

 # Update this path if needed
processor = Wav2Vec2Processor.from_pretrained(MODEL_PATH)
model = Wav2Vec2ForSequenceClassification.from_pretrained(MODEL_PATH)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)
model.eval()

# Define max_length (in terms of audio frames)
MAX_LENGTH = 160000  # Adjust if needed

# Target labels (Numbers 0-9)
TARGET_LABELS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

def predict_audio(audio_path):
    """ Predict the spoken number from the audio file """
    try:
        audio_input, sample_rate = torchaudio.load(audio_path)
    except Exception as e:
        print(f"Error loading audio file: {e}")
        return None

    # Resample and preprocess as before
    if sample_rate != 16000:
        resampler = torchaudio.transforms.Resample(orig_freq=sample_rate, new_freq=16000)
        audio_input = resampler(audio_input)

    # Convert to numpy and preprocess (keeping it as tensor for Wav2Vec2)
    audio_input = audio_input.squeeze()
    inputs = processor(audio_input, sampling_rate=16000, return_tensors="pt", padding=True, truncation=True,max_length=MAX_LENGTH)

    inputs = {key: value.to(device) for key, value in inputs.items()}

    try:
        with torch.no_grad():
            outputs = model(**inputs)
    except Exception as e:
        print(f"Error during prediction: {e}")
        return None

    logits = outputs.logits
    predicted_class = torch.argmax(logits, dim=-1).item()

    return TARGET_LABELS[predicted_class]  # Return the predicted number




@api_view(["POST"])
def evaluate_speech(request):
    """ API endpoint to evaluate speech accuracy """
    file = request.FILES.get("file")
    expected_number = request.POST.get("number")

    # Debug: print file and expected number
    print(f"Received file: {file}")
    print(f"Expected number: {expected_number}")

    if not file or expected_number.lower() not in TARGET_LABELS:
        return Response({"error": "Invalid input"}, status=400)
    print("...................checkpoint1...........................................")

    # Save the received AAC file in a temp directory
    with tempfile.NamedTemporaryFile(delete=False, suffix=".aac") as temp_audio:
        for chunk in file.chunks():
            temp_audio.write(chunk)
        temp_audio_path = temp_audio.name

    print(f"File saved at: {temp_audio_path}")

    # Convert AAC to WAV using pydub
    try:
        audio = AudioSegment.from_file(temp_audio_path, format="aac")
        wav_temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
        audio.export(wav_temp_file.name, format="wav")
        wav_temp_file_path = wav_temp_file.name
        print(f"Converted to WAV at: {wav_temp_file_path}")
    except Exception as e:
        return Response({"error": f"Error converting audio file: {str(e)}"}, status=500)
    print("....................checkpoint2....................................")
    # Predict number from the WAV file
    predicted_number = predict_audio(wav_temp_file_path)
    print("............................checkpoint3.............................")
    # Compute accuracy (Simple match-based)
    accuracy = 100 if predicted_number == expected_number.lower() else 0

    return Response({
        "predicted_number": int(predicted_number),
        "expected_number": expected_number,
        "accuracy": accuracy
    })