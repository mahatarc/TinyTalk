from django.conf import settings
from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import RefreshToken
from django.core.mail import send_mail
from django.contrib.sites.shortcuts import get_current_site
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.template.loader import render_to_string
from django.contrib.auth.tokens import default_token_generator
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.core.validators import validate_email
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from django.http import JsonResponse, HttpResponse
from rest_framework_simplejwt.tokens import UntypedToken
from .serializers import ForgotPasswordSerializer, QuestionSerializer
from django.contrib.auth.forms import SetPasswordForm
from django.shortcuts import render, redirect
from django.contrib.auth import update_session_auth_hash
from django.views import View  
import logging
from rest_framework.decorators import api_view, permission_classes
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from .models import Question, UserProgress  
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

def home(request):
    return HttpResponse("Welcome to TinyTalks")

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_profile(request):
    user = request.user
    user_progress, _ = UserProgress.objects.get_or_create(user=user)

    return Response({
        'username': user.username,
        'email': user.email,
        'latest_score': user_progress.latest_score,  

    })


# Function to generate JWT tokens for a user
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_user_score(request):
    user_progress, _ = UserProgress.objects.get_or_create(user=request.user)
    user_progress.score = request.data.get('score', user_progress.latest_score)
    user_progress.save()
    return Response({'message': 'Score updated successfully'})

class SignupAPIView(APIView):
    permission_classes = [AllowAny]


    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)
    def post(self, request):
        username = request.data.get('username')
        email = request.data.get('email')
        password = request.data.get('password')

        if not username or not email or not password:
            return Response({"error": "All fields are required"}, status=status.HTTP_400_BAD_REQUEST)

        # Check if the email already exists
        if User.objects.filter(email=email).exists():
            return Response({"error": "Email is already registered."}, status=status.HTTP_400_BAD_REQUEST)
            

        user = User.objects.create_user(username=username, email=email, password=password)
        user.is_active = False  # Set the user as inactive until email is verified
        user.save()


        token = default_token_generator.make_token(user)  
        uid = urlsafe_base64_encode(str(user.pk).encode())
        domain = get_current_site(request).domain
        link = f'http://{domain}/verify_email/{uid}/{token}/'
        subject = 'Verify Your Email'
        message = f'Click the following link to verify your email: {link}'

        # Send email
        send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, [email])

        return JsonResponse({"message": "User created. Please verify your email."}, status=status.HTTP_201_CREATED)


class LoginAPIView(APIView):
    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        # Authenticate user with provided credentials
        user = authenticate(username=username, password=password)

        if user is None:
            raise AuthenticationFailed("Invalid username or password")



        if not user.is_active:
            raise AuthenticationFailed("Please verify your email address first.")

   
        tokens = get_tokens_for_user(user)

        return Response({
            "message": "Login successful",
            "tokens": tokens
        }, status=status.HTTP_200_OK)

class ProtectedAPIView(APIView):
    permission_classes = [IsAuthenticated] 

    def get(self, request):

        token = request.headers.get('Authorization', '').split(' ')[1]
        # Retrieve token from request headers
        auth_header = request.headers.get('Authorization')
        if not auth_header or ' ' not in auth_header:
            raise AuthenticationFailed("Missing or invalid Authorization header")
        try:
            UntypedToken(token)  # Manually decode the token
        except Exception as e:
            raise AuthenticationFailed('...............................Invalid token.....................................')
            token = auth_header.split(' ')[1]  # Extract token
            UntypedToken(token)  # Validate token
        except Exception:
            raise AuthenticationFailed("Invalid token. Please log in again.")

        return Response({"message": "You are authenticated!.............................."})

class VerifyEmailAPIView(APIView):
    def get(self, request, uidb64, token):
        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            return JsonResponse({"error": "Invalid token or user not found."}, status=400)

        if default_token_generator.check_token(user, token):
            user.is_active = True  # Mark the user as active after successful verification
            user.save()

            # Render the verification_success.html template
            return render(request, 'verification_success.html')
        else:
            return JsonResponse({"error": "Invalid token."}, status=400)

class ForgotPasswordView(APIView):

    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)

    def post(self, request, *args, **kwargs):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return JsonResponse({"message": "User not found."}, status=status.HTTP_404_NOT_FOUND)
            # Create a password reset token
            token = default_token_generator.make_token(user)
            uid = urlsafe_base64_encode(str(user.pk).encode())
            domain = get_current_site(request).domain
            link = f'http://{domain}/reset_password/{uid}/{token}/'
            # Render the password reset email template
            subject = 'Reset Your Password'
            message = f'Click the following link to reset your password: {link}'
            # Send the password reset email
            send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, [email])
            return JsonResponse({"message": "Password reset email sent!"}, status=status.HTTP_200_OK)
        return JsonResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Set up logging to capture form data and errors
logger = logging.getLogger(__name__)

class PasswordResetConfirmView(View):
    def get(self, request, uidb64, token):
        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            return JsonResponse({"message": "Invalid or expired link."}, status=400)
        
        # Token validation is done later on POST request
        return render(request, 'password_reset_confirm.html', {'uidb64': uidb64, 'token': token})

    def post(self, request, uidb64, token):
        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            return JsonResponse({"message": "Invalid or expired link."}, status=400)

        if not default_token_generator.check_token(user, token):
            return JsonResponse({"message": "Invalid or expired link."}, status=400)

        new_password = request.POST.get('new_password')
        confirm_password = request.POST.get('confirm_password')

        # Check if the passwords match
        if new_password != confirm_password:
            return JsonResponse({"message": "Passwords do not match."}, status=400)

        # Set the new password for the user
        user.set_password(new_password)
        user.save()

        return JsonResponse({"message": "Password has been reset successfully."}, status=200)


        # Token validation
        auth_header = request.headers.get('Authorization')
        if not auth_header or ' ' not in auth_header:
            raise AuthenticationFailed("Missing or invalid Authorization header")
        
        token = auth_header.split(' ')[1]
        try:
            UntypedToken(token)
        except Exception:
            raise AuthenticationFailed("Invalid token. Please log in again.")

        return Response({"message": "You are authenticated!"})



class VerifyEmailAPIView(APIView):
    def get(self, request, uidb64, token):
        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            return JsonResponse({"error": "Invalid token or user not found."}, status=400)

        if default_token_generator.check_token(user, token):
            user.is_active = True  # Mark the user as active after successful verification
            user.save()
            return JsonResponse({"message": "Email verified successfully!"}, status=200)
        else:
            return JsonResponse({"error": "Invalid token."}, status=400)


class ForgotPasswordView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return JsonResponse({"message": "User not found."}, status=status.HTTP_404_NOT_FOUND)
            token = default_token_generator.make_token(user)
            uid = urlsafe_base64_encode(str(user.pk).encode())
            domain = get_current_site(request).domain
            link = f'http://{domain}/reset_password/{uid}/{token}/'
            subject = 'Reset Your Password'
            message = f'Click the following link to reset your password: {link}'
            send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, [email])
            return JsonResponse({"message": "Password reset email sent!"}, status=status.HTTP_200_OK)
        return JsonResponse(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


logger = logging.getLogger(__name__)

class PasswordResetConfirmView(View):
    def get(self, request, uidb64, token):
        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            return JsonResponse({"message": "Invalid or expired link."}, status=400)
        
        return render(request, 'password_reset_confirm.html', {'uidb64': uidb64, 'token': token})

    def post(self, request, uidb64, token):
        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            return JsonResponse({"message": "Invalid or expired link."}, status=400)

        if not default_token_generator.check_token(user, token):
            return JsonResponse({"message": "Invalid or expired link."}, status=400)

        new_password = request.POST.get('new_password')
        confirm_password = request.POST.get('confirm_password')

        if new_password != confirm_password:
            return JsonResponse({"message": "Passwords do not match."}, status=400)

        user.set_password(new_password)
        user.save()

        return JsonResponse({"message": "Password has been reset successfully."}, status=200)

class AdaptiveQuizAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        user_progress, _ = UserProgress.objects.get_or_create(user=user)

        # Get difficulty from request (fallback to last_difficulty)
        requested_difficulty = request.query_params.get('difficulty', user_progress.last_difficulty)

        # Update user's last_difficulty if requested explicitly
        if requested_difficulty != user_progress.last_difficulty:
            user_progress.last_difficulty = requested_difficulty
            user_progress.save()

        # Fetch questions based on requested difficulty
        questions = Question.objects.filter(difficulty=requested_difficulty)
        correctly_answered_questions = user_progress.correct_questions.filter(difficulty=requested_difficulty)

        if correctly_answered_questions.count() == questions.count() and questions.count() > 0:
            next_difficulty = self.get_next_difficulty(requested_difficulty)
            user_progress.last_difficulty = next_difficulty
            user_progress.save()
            return Response({
                "message": "Congratulations! You have completed all questions at this difficulty.",
                "next_difficulty": next_difficulty
            })

        unanswered_questions = questions.exclude(id__in=user_progress.correct_questions.values_list('id', flat=True))

        if not unanswered_questions.exists():
            return Response({"message": "No more questions available for this difficulty."}, status=404)

        # Pick a random unanswered question
        question = unanswered_questions.order_by('?').first()

        serializer = QuestionSerializer(question)
        return Response(serializer.data)

    def get_next_difficulty(self, current_difficulty):
        difficulty_order = ['easy', 'medium', 'hard']
        current_index = difficulty_order.index(current_difficulty)
        return difficulty_order[min(current_index + 1, len(difficulty_order) - 1)]

class AnswerQuizAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        question_id = request.data.get('question_id')
        user_answer = request.data.get('answer')

        if not question_id or not user_answer:
            return Response({"error": "Missing question ID or answer"}, status=400)

        question = get_object_or_404(Question, id=question_id)
        user = request.user
        user_progress, _ = UserProgress.objects.get_or_create(user=user)

        correct = user_answer.strip().lower() == question.answer.strip().lower()

        if correct:
            # Avoid duplicate entries
            if not user_progress.correct_questions.filter(id=question.id).exists():
                user_progress.correct_answers += 1
                user_progress.correct_questions.add(question)

                # Add 10 points for correct answer
                user_progress.latest_score += 10
        else:
            if not user_progress.incorrect_questions.filter(id=question.id).exists():
                user_progress.incorrect_answers += 1
                user_progress.incorrect_questions.add(question)

        user_progress.total_answers += 1
        user_progress.save()

        # Return the updated score, current difficulty, and the question's image/audio info
        return Response({
            "message": "Correct!" if correct else "Incorrect.",
            "correct_answer": question.answer,
            "current_difficulty": user_progress.last_difficulty,
            "latest_score": user_progress.latest_score,  # Return updated score
            "question_data": {
                "image": question.image,
                "audio": question.audio,
                "question_text": question.question_text,
                "options": question.options,
            }
        })


class UserProgressAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        user_progress, _ = UserProgress.objects.get_or_create(user=user)

        return Response({
            "latest_score": user_progress.latest_score,
            "correct_answers": user_progress.correct_answers,
            "incorrect_answers": user_progress.incorrect_answers,
            "total_answers": user_progress.total_answers,
            "last_difficulty": user_progress.last_difficulty
        })
    
class RestartQuizAPIView(APIView):
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        user = request.user
        user_progress, _ = UserProgress.objects.get_or_create(user=user)

        # Reset user progress
        user_progress.last_difficulty = 'easy'  # Difficulty reset to 'easy'
        user_progress.correct_answers = 0
        user_progress.incorrect_answers = 0
        user_progress.total_answers = 0
        user_progress.latest_score = 0
        user_progress.correct_questions.clear()  # Remove all correct questions
        user_progress.incorrect_questions.clear()  # Remove all incorrect questions
        user_progress.save()

        # Fetch questions based on 'easy' difficulty (similar to AdaptiveQuizAPIView)
        easy_questions = Question.objects.filter(difficulty='easy')
        
        # If needed, you can return a random subset of questions
        # If you want to return the first few questions, you can adjust accordingly.
        # Example: getting the first 5 easy questions
        easy_questions = easy_questions[:5]  

        # Serialize the questions to return
        question_data = [{"question_id": q.id, "question_text": q.question_text, "options": q.options} for q in easy_questions]

        return Response({
            "message": "Quiz restarted successfully! Difficulty set to 'easy'.",
            "last_difficulty": user_progress.last_difficulty,
            "latest_score": user_progress.latest_score,
            "questions": question_data  # Return easy-level questions
        })
