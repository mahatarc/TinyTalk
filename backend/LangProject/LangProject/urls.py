from django.contrib import admin
from django.urls import include, path
from LangApp import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/lang/', include('LangApp.urls')),  # Make sure LangApp URLs are included
    path('api/deploy/', include('model_deploy.urls')),  # Include model_deploy's URLs
    path('', views.home, name='home'),
]
