from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import SignupAPIView, LoginAPIView,ProtectedAPIView,VerifyEmailAPIView 
from LangApp.views import ForgotPasswordView, PasswordResetConfirmView 

urlpatterns = [
    path('protected/', ProtectedAPIView.as_view(), name='protected_api'),
    path('signup/', SignupAPIView.as_view(), name='signup'),
    path('login/', LoginAPIView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),  # Refresh JWT token
    path('verify_email/<uidb64>/<token>/', VerifyEmailAPIView.as_view(), name='verify_email'),  # Add this line
    path('api/password_reset/', ForgotPasswordView.as_view(), name='password_reset'),
    path('reset_password/<uidb64>/<token>/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),  # Add this line
]
