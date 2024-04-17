"""
URL configuration for omnistudyin_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from data_logic.views.views_ad import *
from data_logic.views.views_student import *
from data_logic.views.views_friends import *

urlpatterns = [
    path('admin/', admin.site.urls),
    # Testings
    path('value/', get_value, name='get_value'),
    path('test', test, name='test'),
    path('test_relationship/', test_relationship, name='test_relationship'),
    # JWT
    path('update_jwt/', update_jwt, name='update_jwt'),
    # Login/Register = Student
    path('register/', register_student, name='register_student'),
    path('login/', login_student, name='login_student'),
    path('get_session_student/', get_session_student, name='get_student'),
    path('get_all_students/', get_all_students, name='get_all_students'),
    path('delete_session_student/', delete_session_student, name='delete_student'),
    path('query_students/', query_students, name='query_students'),
    # Ad_group
    path('create_adgroup/', create_ad_group, name='adgroup'),
    path('get_adgroups/', get_ad_groups, name='get_adgroups'),
    path('change_adgroup/', change_ad_group, name='change_adgroup'),
    path('delete_adgroup/', delete_ad_group, name='delete_adgroup'),
    # Ad
    # get_ads_of_group is a POST request! --> needs to get the name of the ad group (ad_group_name) as a parameter in the request!
    path('get_ads_of_group/', get_ads_of_group, name='get_ads'),
    # create_ads_in_group needs to get the name of the ad group (ad_group_name) as a parameter in the request (additionally to the standard params)!
    path('create_ads_in_group/', create_ads_in_group, name='create_ads'),
    path('change_ad_in_group/', change_ad_in_group, name='change_ad'),
    path('delete_ad_in_group/', delete_ad_in_group, name='delete_ad'),
    # search
    path('query_ads/', query_ads, name='query_ads'),
    path('query_adgroups/', query_ad_groups, name='search_adgroups'),
    path('query_all/', query_all, name='search_all'),
    path('query_ads_by_group/', query_ads_by_group, name='search_ad_in_group'),
    # friends
    path('get_friends/', get_friends, name='get_friends'),
    path('send_friend_request/', send_friend_request, name='send_friend_request'),
    path('accept_friend_request/', accept_friend_request,
         name='accept_friend_request'),
    path('delete_friend/', delete_friend, name='delete_friend'),
]
