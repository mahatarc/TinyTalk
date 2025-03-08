from django.urls import path
from . import views  # Import views from the same app

urlpatterns = [
    path("evaluate_speech_asr/", views.evaluate_speech_asr, name="evaluate_speech_asr"),  # Correct URL pattern
]
