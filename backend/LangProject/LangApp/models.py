from django.db import models
from django.contrib.auth.models import User  

# Create your models here.
class Data(models.Model):
    name = models.CharField(max_length=200)
    description = models.CharField(max_length=500)
    
class Question(models.Model):
    image = models.CharField(max_length=255, blank=True, null=True)
    audio = models.CharField(max_length=255, blank=True, null=True) 
    question_text = models.CharField(max_length=255)
    options = models.JSONField() 
    answer = models.CharField(max_length=255)
    difficulty = models.CharField(max_length=50)

    def __str__(self):
        return self.question_text


class UserProgress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    last_difficulty = models.CharField(choices=[('easy', 'Easy'), ('medium', 'Medium'), ('hard', 'Hard')], max_length=10, default='easy')
    correct_answers = models.IntegerField(default=0)
    incorrect_answers = models.IntegerField(default=0)
    total_answers = models.IntegerField(default=0)
    latest_score = models.IntegerField(default=0)
    correct_questions = models.ManyToManyField(Question, related_name='correct_answers')

    incorrect_questions = models.ManyToManyField(Question, related_name='incorrect_answers', blank=True)

    def __str__(self):
        return f"{self.user.username} - Score: {self.latest_score}"