import os
import django

# Set up Django environment
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "LangProject.settings")
django.setup()

from LangApp.models import Question

# Sample questions to insert
questions = [
    {
        "image": "images/apple.png",
        "question_text": "Identify from the picture:",
        "options": ["स्याउ", "सुन्तला", "केरा", "आप"],
        "answer": "स्याउ",
        "difficulty": "easy",
    },
    {
        "image": "images/elephant.png",
        "question_text": "Identify from the picture:",
        "options": ["बाघ", "हात्ती", "कुकुर", "गाई"],
        "answer": "हात्ती",
        "difficulty": "medium",
    },
    {
        "image": "images/vegetables.png",
        "question_text": "Identify from the picture:",
        "options": ["फलफुल", "तरकारी", "भात", "बर्गर"],
        "answer": "तरकारी",
        "difficulty": "hard",
    },
]

# Insert questions into the database
def seed_database():
    for q in questions:
        Question.objects.create(
            image=q["image"],
            question_text=q["question_text"],
            options=q["options"],  # This should match the model field name
            answer=q["answer"],
            difficulty=q["difficulty"],
        )
        print(f"Added question: {q['question_text']}")

if __name__ == "__main__":
    seed_database()
