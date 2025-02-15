from django.contrib.auth import authenticate
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import RefreshToken
from .serializers import SignupSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.http import HttpResponse
from rest_framework_simplejwt.tokens import UntypedToken
from rest_framework.exceptions import AuthenticationFailed

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
    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "User created successfully"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

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
            "tokens": tokens
        }, status=status.HTTP_200_OK)


class ProtectedAPIView(APIView):
    permission_classes = [IsAuthenticated]  # Only authenticated users can access

    def get(self, request):
        # Token validation (optional, in case you want to manually validate)
        token = request.headers.get('Authorization', '').split(' ')[1]
        try:
            UntypedToken(token)  # Manually decode the token
        except Exception as e:
            raise AuthenticationFailed('...............................Invalid token.....................................')

        return Response({"message": "You are authenticated!.............................."})