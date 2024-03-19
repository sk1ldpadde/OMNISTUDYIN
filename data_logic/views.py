from .serializers import AdSerializer  # You need to create this serializer
from .models import Ad
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import json

from argon2 import PasswordHasher, exceptions

from data_logic.util import check_credentials, check_profanity

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


@api_view(['GET'])
def get_session_student(request):
    data = request.data
    try:
        # TODO: Just get the student of the session!!!
        student = Student.nodes.get(email=data['email'])
        serializer = StudentSerializer(student)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Student.DoesNotExist:
        return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
def get_all_students(request):
    students = Student.nodes.all()
    serializer = StudentSerializer(students, many=True)
    return Response(serializer.data)


@api_view(['PUT'])
def change_session_student(request):
    data = request.data
    try:
        # TODO: Just get the student of the session!!!
        student = Student.nodes.get(email=data['old_email'])
    except Student.DoesNotExist:
        return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)

    # huge if block to check which attributes are requested to be changed:
    if data["forename"] is not None and data["surname"] is not None:
        student.forename = data['forename']
        student.surname = data['surname']
    if data["dob"] is not None:
        student.dob = data['dob']
    if data["new_email"] is not None:
        student.email = data['new_email']
    if data["password"] is not None:
        student.password = data['password']
    if data["bio"] is not None:
        student.bio = data['bio']
    # TODO: when the uniname changes, the zipcode should be updated as well @daniel
    if data["uni_name"] is not None and data["degree"] is not None and data["semester"] is not None:
        student.uni_name = data['uni_name']
        student.degree = data['degree']
        student.semester = data['semester']
    if data["profile_picture"] is not None:
        student.profile_picture = data['profile_picture']
    # if data["zip_code"] is not None:
    #     student.zip_code = data['zip_code']
    if data["interests_and_goals"] is not None:
        student.interests_and_goals = data['interests_and_goals']

    student.save()
    return Response({'info': 'successfully changed student.'}, status=status.HTTP_200_OK)


# TODO define a view for simple student matching algorithm


@api_view(['GET'])
def get_ad_groups(request):
    ad_groups = Ad_Group.nodes.all()
    serializer = AdGroupSerializer(ad_groups, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def create_ad_group(request):
    data = request.data

    # Check if an ad group with the provided name already exists
    # try catch block to handle the case where the ad group does not exist
    try:
        existing_ad_group = Ad_Group.nodes.get(name=data['name'])
    except Ad_Group.DoesNotExist:
        existing_ad_group = None

    if existing_ad_group:
        return Response({'error': 'An ad group with this name already exists.'}, status=status.HTTP_400_BAD_REQUEST)

    if data['name'] is None or data['description'] is None:
        return Response({'error': 'Please provide a name and a description for the ad group.'}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data['name']) or check_profanity(data['description']):
        return Response({'error': 'Please provide a name and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
    # Create a new ad group
    # TODO: validate payload!
    # TODO: connect the session holder student as the creator of the ad group
    # admin= Student.nodes.get(data['sessionholder']))?? bzw TODO: decode den Sessiontoken!
    ad_group = Ad_Group(name=data['name'], description=data['description'])
    ad_group.save()
    # Serialize the new ad group
    serializer = AdGroupSerializer(ad_group)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['PUT'])
def change_ad_group(request):
    data = request.data
    # Check if an ad group with the provided name already exists
    # try catch block to handle the case where the ad group does not exist
    try:
        ad_group = Ad_Group.nodes.get(name=data['old_name'])
    except Ad_Group.DoesNotExist:
        return Response({'error': 'An ad group with this name does not exist. (please provide an old_name parameter)'}, status=status.HTTP_400_BAD_REQUEST)

    # TODO: check if session holder is the admin of the ad group!!

    if data['new_name'] is None and data['description'] is None:
        return Response({'error': 'Please provide a name or a description for the ad group.'}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data['new_name']) or check_profanity(data['description']):
        return Response({'error': 'Please provide a name and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)

    # if block to check which attributes are requested to be changed:
    if data["new_name"] is not None:
        ad_group.name = data['new_name']
    if data["description"] is not None:
        ad_group.description = data['description']
    ad_group.save()
    return Response({'info': 'successfully changed ad group.'}, status=status.HTTP_200_OK)


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

        return Response(serializer.data, status=status.HTTP_200_OK)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
def create_ads_in_group(request):
    data = request.data
    # extract the ad group name from the request
    ad_group_name = data['ad_group_name']
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    if data["title"] is None or data["description"] is None:
        return Response({"info": "please provide title and description for the ad"}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data['title']) or check_profanity(data['description']):
        return Response({'error': 'Please provide a title and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
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


@api_view(['PUT'])
def change_ad_in_group(request):
    data = request.data
    # extract the ad group name from the request
    ad_group_name = data['ad_group_name']
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    if data.get("new_title") is None and data.get("description") is None:
        return Response({"info": "please provide a title or description for the ad"}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data['title']) or check_profanity(data['description']):
        return Response({'error': 'Please provide a title and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)

    try:
        # get the ad
        ad = ad_group.ads.get(title=data['old_title'])
        # change the ad
        # if block to check which attributes are requested to be changed:
        if data["new_title"] is not None:
            ad.title = data['new_title']
        if data["description"] is not None:
            ad.description = data['description']
        if data["image"] is not None:
            ad.image = data['image']
        ad.save()
        return Response({'info': 'successfully changed ad.'}, status=status.HTTP_200_OK)
    except Ad.DoesNotExist:
        return Response({'error': 'Ad not found in the given group'}, status=status.HTTP_404_NOT_FOUND)
