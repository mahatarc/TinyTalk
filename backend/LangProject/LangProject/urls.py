from django.contrib import admin
from django.urls import include, path
from django.http import HttpResponse
from LangApp import views


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('LangApp.urls')),
    path('', views.home, name='home'),  # Add this line for the root URL
    path('verify_email/<uidb64>/<token>/', views.VerifyEmailAPIView.as_view(), name='verify_email'), 

]