from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import SignupAPIView, LoginAPIView,ProtectedAPIView

urlpatterns = [
    path('protected/', ProtectedAPIView.as_view(), name='protected_api'),
    path('signup/', SignupAPIView.as_view(), name='signup'),
    path('login/', LoginAPIView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),  # Refresh JWT token
]