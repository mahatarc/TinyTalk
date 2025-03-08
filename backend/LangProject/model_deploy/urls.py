from django.urls import path
from . import views  # Import views from the same app

urlpatterns = [
    path("evaluate_speech/", views.evaluate_speech, name="evaluate_speech"),  # Correct URL pattern
]
