from django.contrib import admin
from django.urls import include, path
from LangApp import views
from django.contrib.auth import views as auth_views
from LangApp.views import ForgotPasswordView, PasswordResetConfirmView, user_profile  # Import the view


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('LangApp.urls')),
    path('', views.home, name='home'),  # for root URL
    path('profile/', user_profile, name='user_profile'),
    path('api/deploy/', include('model_deploy.urls')),
    path('verify_email/<uidb64>/<token>/', views.VerifyEmailAPIView.as_view(), name='verify_email'), 
    path('api/password_reset/', ForgotPasswordView.as_view(), name='password_reset'),
    path('reset_password/<uidb64>/<token>/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),  # Add this line
]
