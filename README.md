# TinyTalks – NEPALI LEARNING APP FOR KIDS 

TinyTalks is a **speech-recognition–driven mobile application** for early-stage Nepali language learning (ages 4–8).  
The system integrates a **fine-tuned Wav2Vec2 Automatic Speech Recognition (ASR) model** to perform **character-level recognition** for pronunciation feedback in a low-resource language setting.


## System Stack

- **Frontend:** Flutter  
- **Backend:** Python, Django (REST API + ASR inference)  
- **Database:** MySQL  
- **ML Framework:** PyTorch, HuggingFace Transformers  
- **ASR Model:** Wav2Vec2 (fine-tuned for Nepali)


## Nepali ASR Model

### Model Overview
The base Automatic Speech Recognition model used in this project is sourced from Hugging Face:

- **facebook/wav2vec2-base-960h**  
  https://huggingface.co/facebook/wav2vec2-base-960h  

The model is fine-tuned on a custom Nepali speech dataset for character-level classification and pronunciation feedback.

- **Architecture:** Transformer-based, self-supervised speech representation  
- **Input:** Raw audio waveform (16 kHz, mono)  
- **Output:** Class-level predictions (Nepali digits & characters)  
- **Task Type:** Supervised classification (isolated speech units)


### Dataset
- **Total samples:** 2,593  
- **Train / Validation:** 80% / 20%  
- **Sources:**
  - Public GitHub datasets  
  - Budhanilkantha Kids Montessori Academy  
  - Family and community contributors  

**Label Space:**  
Nepali digits (0–9) and Devanagari vowels/consonants (e.g., अ, आ, इ, उ, क, ख, ग, घ)

### Audio Preprocessing
- WAV conversion  
- Resampling to 16 kHz  
- Amplitude normalization  
- Noise reduction  
- ~1 second clipping  
- Multiple speaking speeds (slow / normal / fast)


### Training Configuration
- Epochs: 60  
- Batch size: 16  
- Learning rate: 3 × 10⁻⁵  
- Optimizer: Adam (weight decay = 0.01)  
- Seed: 42  


### Performance
- **Training Accuracy:** 83.99%  
- **Validation Accuracy:** 75.53%  

Observed errors are primarily due to **phonetically similar Nepali sounds** (e.g., उ vs ऊ, ग vs घ) and limited dataset diversity.


## Demo

**Working Video Demo**

A short video demonstrating the end-to-end workflow of TinyTalks:
- Mobile UI interaction
- Child speech input
- Backend ASR inference
- Pronunciation feedback generation

**Watch the demo:**  
https://drive.google.com/drive/folders/1_yM6iyj3Ngh0QEwIt08hRK77_HKHRHOG?usp=drive_link


