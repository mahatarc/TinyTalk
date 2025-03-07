from django.conf import settings
from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import RefreshToken
from django.core.mail import send_mail
from django.contrib.sites.shortcuts import get_current_site
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.contrib.auth.tokens import default_token_generator
from django.contrib.auth.models import User
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from django.http import JsonResponse, HttpResponse
from rest_framework_simplejwt.tokens import UntypedToken
from .serializers import ForgotPasswordSerializer, QuestionSerializer
from django.shortcuts import render
from django.views import View  
import logging
from rest_framework.decorators import api_view, permission_classes
from .models import Question, UserProgress  
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
def home(request):
    return HttpResponse("Welcome to TinyTalks")

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_profile(request):
    user = request.user
    return Response({
        'username': user.username,
        'email': user.email,
    })

# Function to generate JWT tokens for a user
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

class SignupAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get('username')
        email = request.data.get('email')
        password = request.data.get('password')

        if not username or not email or not password:
            return Response({"error": "All fields are required"}, status=status.HTTP_400_BAD_REQUEST)

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
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

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
        # Token validation
        token = request.headers.get('Authorization', '').split(' ')[1]
        auth_header = request.headers.get('Authorization')
        if not auth_header or ' ' not in auth_header:
            raise AuthenticationFailed("Missing or invalid Authorization header")
        try:
            UntypedToken(token) 
        except Exception as e:
            raise AuthenticationFailed('...............................Invalid token.....................................')
            token = auth_header.split(' ')[1] 
            UntypedToken(token) 
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

    def get(self, request):
        last_difficulty = request.session.get('last_difficulty', 'medium')

        question = Question.objects.filter(difficulty=last_difficulty).order_by('?').first()

        if not question:
            if last_difficulty == 'hard':
                question = Question.objects.filter(difficulty='medium').order_by('?').first()
            elif last_difficulty == 'medium':
                question = Question.objects.filter(difficulty='easy').order_by('?').first()
            else:
                question = Question.objects.filter(difficulty='hard').order_by('?').first()

        if question:
            serializer = QuestionSerializer(question)
            return Response(serializer.data)
        else:
            return Response({"message": "No questions available."}, status=404)

class AnswerQuizAPIView(APIView):

    def post(self, request):
        question_id = request.data.get('question_id')
        user_answer = request.data.get('answer')

        question = get_object_or_404(Question, id=question_id)

        # Get the currently logged-in user
        user = request.user

        user_progress, created = UserProgress.objects.get_or_create(user=user)

        if user_answer.lower() == question.answer.lower():
            next_difficulty = self.get_next_difficulty(question.difficulty, correct=True)

            user_progress.correct_answers += 1
        else:
            next_difficulty = self.get_next_difficulty(question.difficulty, correct=False)

            user_progress.incorrect_answers += 1

        user_progress.total_answers += 1

        user_progress.save()

        request.session['last_difficulty'] = next_difficulty

        return Response({"message": f"Answer received. Next question difficulty: {next_difficulty}"})

    def get_next_difficulty(self, current_difficulty, correct):
        difficulty_order = ['easy', 'medium', 'hard']
        current_index = difficulty_order.index(current_difficulty)

        # If the answer was correct, move to a higher difficulty level
        if correct:
            if current_index < len(difficulty_order) - 1:
                return difficulty_order[current_index + 1]
            return current_difficulty
        else:
            # If the answer was incorrect, move to a lower difficulty level
            if current_index > 0:
                return difficulty_order[current_index - 1]
            return current_difficulty