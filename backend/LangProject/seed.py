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
        "image": "images/cat.png",
        "question_text": "Identify from the picture:",
        "options": ["बिरालो", "कुकुर", "केरा", "आप"],
        "answer": "बिरालो",
        "difficulty": "easy",
    },
    {
        "image": "images/dog.png",
        "question_text": "Identify from the picture:",
        "options": ["बिरालो", "कुकुर", "केरा", "आप"],
        "answer": "कुकुर",
        "difficulty": "easy",
    },

    # medium
    {
        "image": "images/quiz_1.png",
        "question_text": "Identify from the picture:",
        "options": ['३', '१', '८', '६'],
        "answer": '१',
        "difficulty": "medium",
    },

    {
        "image": "images/quiz_2.png",
        "question_text": "Identify from the picture:",
        "options": ['९', '२', '८', '६'],
        "answer": '२',
        "difficulty": "medium",
    },

    {
        "image": "images/quiz_3.png",
        "question_text": "Identify from the picture:",
        "options": ['३', '१', '८', '६'],
        "answer": '३',
        "difficulty": "medium",
    },

    {
        "image": "images/quiz_4.png",
        "question_text": "Identify from the picture:",
        "options": ['३', '१', '४', '६'],
        "answer": '४',
        "difficulty": "medium",
    },

    # hard
    {
        "image": "images/woodspeaker.png",
        "audio": "audio/Zero.wav",
        "question_text": "Identify the sound:",
        "options": ["०", '४', '८', '२'],
        "answer": '०',
        "difficulty": "hard",
    },

    {
        "image": "images/woodspeaker.png",
        "audio": "audio/One.wav",
        "question_text": 'Identify the sound:',
        "options": ['३', '१', '८', '६'],
        "answer": '१',
        "difficulty": "hard",
    },

    {
        "image": "images/woodspeaker.png",
        "audio": "audio/Two.wav",
        "question_text": 'Identify the sound:',
        "options": ['९', '२', '८', '६'],
        "answer": '२',
        "difficulty": "hard",
    },

    {
        "image": "images/woodspeaker.png",
        "audio": "audio/Three.wav",
        "question_text": 'Identify the sound:',
        "options": ['३', '१', '८', '६'],
        "answer": '३',
        "difficulty": "hard",
    },

    {
        "image": "images/woodspeaker.png",
        "audio": "audio/Four.wav",
        "question_text": 'Identify the sound:',
        "options": ['९', '१', '४', '६'],
        "answer": '४',
        "difficulty": "hard",
    },
]

# Insert questions into the database
def seed_database():
    for q in questions:
        # Check if the question has both image and audio
        if q.get("audio"):
            if not Question.objects.filter(audio=q["audio"]).exists():
                Question.objects.create(
                    audio=q["audio"],
                    image=q["image"],
                    question_text=q["question_text"],  # Corrected key here
                    options=q["options"],
                    answer=q["answer"],
                    difficulty=q["difficulty"]
                )
                print(f"Added audio question: {q['question_text']}")
        elif q.get("image"):
            if not Question.objects.filter(image=q["image"]).exists():
                Question.objects.create(
                    image=q["image"],
                    question_text=q["question_text"],  # Corrected key here
                    options=q["options"],
                    answer=q["answer"],
                    difficulty=q["difficulty"]
                )
                print(f"Added image question: {q['question_text']}")
        else:
            print(f"Question missing image or audio: {q['question_text']}")

if __name__ == "__main__":
    seed_database()