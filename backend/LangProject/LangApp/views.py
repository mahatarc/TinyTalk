from django.contrib.auth import authenticate
from django.http import HttpResponse
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import RefreshToken, UntypedToken
from .serializers import SignupSerializer

def home(request):
    return HttpResponse("Welcome to TinyTalks")

# Function to generate JWT tokens for a user
def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

# Signup API
class SignupAPIView(APIView):
    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "User created successfully"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Login API
class LoginAPIView(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        user = authenticate(username=username, password=password)

        if user is None:
            raise AuthenticationFailed("Invalid username or password")

        tokens = get_tokens_for_user(user)  # Generate JWT tokens

        return Response({
            "message": "Login successful",
            "tokens": tokens,
            "user": {
                "name": user.username,   # Send the username as "name"
                "email": user.email      # Send the email
            }
        }, status=status.HTTP_200_OK)

# Protected API - Requires Authentication
class ProtectedAPIView(APIView):
    permission_classes = [IsAuthenticated]  # Ensures only authenticated users can access

    def get(self, request):
        # Retrieve token from request headers
        auth_header = request.headers.get('Authorization')

        if not auth_header or ' ' not in auth_header:
            raise AuthenticationFailed("Missing or invalid Authorization header")

        try:
            token = auth_header.split(' ')[1]  # Extract token
            UntypedToken(token)  # Validate token
        except Exception:
            raise AuthenticationFailed("Invalid token. Please log in again.")

        return Response({"message": "You are authenticated!"}, status=status.HTTP_200_OK)
