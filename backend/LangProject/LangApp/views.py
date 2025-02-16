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
from rest_framework.permissions import AllowAny, IsAuthenticated  # Added IsAuthenticated import
from rest_framework.response import Response
from django.http import JsonResponse, HttpResponse
from rest_framework_simplejwt.tokens import UntypedToken


def home(request):
    return HttpResponse("Welcome to TinyTalks")


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

        # Create user but keep inactive
        user = User.objects.create_user(username=username, email=email, password=password)
        user.is_active = False  # Set the user as inactive until email is verified
        user.save()

        # Send verification email
        token = default_token_generator.make_token(user)  # Use default_token_generator here
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

        # Authenticate user with provided credentials
        user = authenticate(username=username, password=password)

        if user is None:
            raise AuthenticationFailed("Invalid username or password")

        # Check if the user's email is verified (is_active must be True)
        if not user.is_active:
            raise AuthenticationFailed("Please verify your email address first.")

        # If email is verified, generate tokens and return them
        tokens = get_tokens_for_user(user)

        return Response({
            "message": "Login successful",
            "tokens": tokens
        }, status=status.HTTP_200_OK)




class ProtectedAPIView(APIView):
    permission_classes = [IsAuthenticated]  # Only authenticated users can access

    def get(self, request):
        # Token validation (optional, in case you want to manually validate)
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
        return Response({"message": "You are authenticated!"}, status=status.HTTP_200_OK)


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