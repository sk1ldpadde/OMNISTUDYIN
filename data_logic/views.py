from .serializers import AdSerializer  # You need to create this serializer
from .models import Ad
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import json

from argon2 import PasswordHasher, exceptions

from data_logic.util import check_credentials

import jwt

from datetime import datetime, timedelta

from data_logic.models import Student, Ad_Group, Ad

from data_logic.serializers import StudentSerializer, AdGroupSerializer, AdSerializer

# Create your views here.

# easy test view for debugging


@api_view(['GET'])
def get_value(request):
    matching = Student.nodes.filter(
        email='inf22111@lehre.dhbw-stuttgart.de').first()
    return Response({'value': matching.semester})


@api_view(['GET'])
def test(request):
    return Response({'info': 'test successful.'},
                    status=status.HTTP_200_OK)


@api_view(['POST'])
def register_student(request):
    student_data = json.loads(request.body)

    # Check if payload is valid

    # Check if user does not already exist
    # Note: email is the unique property
    matching_node = Student.nodes.filter(email=student_data['email'])

    if matching_node:
        return Response({'info': 'student with given email already exists.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # Create and store a salted hash of the given password
    ph = PasswordHasher()
    student_data['password'] = ph.hash(student_data['password'])

    # convert dob from string back a datetime object
    student_data['dob'] = datetime.strptime(student_data['dob'], "%d-%m-%Y")

    # Create new user and save
    new_student_node = Student(**student_data)
    new_student_node.save()

    # Return success
    return Response({'info': 'successfully registered new student.'},
                    status=status.HTTP_200_OK)


@api_view(['POST'])
def login_student(request):
    login_data = json.loads(request.body)

    # TODO: Check if payload is valid

    student_node = Student.nodes.get(email=login_data['email'])

    # Check if student node exists
    if student_node is None:
        return Response({'info': 'student with given email doesnt not exist.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # Check credentials
    if check_credentials(student_node.password, login_data['password']):
        # Credentials are correct, generate JWT
        jwt_payload = {
            'sub': student_node.email,
            'exp': datetime.now() + timedelta(days=1)  # Token expiration time
        }

        # TODO Find a way to store the secret key
        secret_key = "12345"
        # TODO: module has not attribute encode error ???
        jwt_token = secret_key
        # jwt_token = jwt.encode(jwt_payload, secret_key, algorithm='HS256')

        return Response({'info': 'login successfull.', 'jwt': jwt_token},
                        status=status.HTTP_200_OK)

    else:
        return Response({'info': 'login attempt failed. wrong credentials.'},
                        status=status.HTTP_400_BAD_REQUEST)


# TODO define a view for simple student matching algorithm


@api_view(['GET'])
def get_ad_groups(request):
    ad_groups = Ad_Group.objects.all()
    serializer = AdGroupSerializer(ad_groups, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def create_ad_group(request):
    data = request.data
    # Create a new ad group
    # TODO: validate payload!
    # TODO: connect the session holder student as the creator of the ad group
    # admin= Student.nodes.get(data['sessionholder']))?? bzw TODO: decode den Sessiontoken!
    ad_group = Ad_Group(name=data['name'], description=data['description'])
    ad_group.save()
    # Serialize the new ad group
    serializer = AdGroupSerializer(ad_group)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


# needs to get the name of the ad group (ad_group_name) as a parameter in the request!


@api_view(['POST'])
def get_ads_of_group(request):
    data = request.data
    # extract the ad group name from the request
    ad_group_name = data['ad_group_name']
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)
        # get all ads of the ad group
        ads = ad_group.ads.all()
        # Serialize the queryset
        serializer = AdSerializer(ads, many=True)

        return Response(serializer.data)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
def create_ads_in_group(request):
    data = request.data
    # extract the ad group name from the request
    ad_group_name = data['ad_group_name']
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)
        # create and save the ad
        # TODO: connect the session holder student as the admin of the ad group
        ad = Ad(title=data["title"],
                description=data["description"], image=data["image"])
        ad.save()
        # connect the ad to the ad group
        ad_group.ads.connect(ad)

        return Response({'info': f'successfully created ad in {ad_group_name}.'},
                        status=status.HTTP_200_OK)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)
