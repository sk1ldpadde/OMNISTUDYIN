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

# ------------------TEST------------------#


@api_view(['GET'])
def get_value(request):
    matching = Student.nodes.filter(
        email='inf22111@lehre.dhbw-stuttgart.de').first()
    return Response({'value': matching.semester})


@api_view(['GET'])
def test(request):
    return Response({'info': 'test successful.'},
                    status=status.HTTP_200_OK)

# ------------------TEST-END------------------#

# ------------------STUDENT------------------#


@api_view(['POST'])
def register_student(request):
    student_data = json.loads(request.body)

    # Check if payload is valid

    # Check if user does not already exist
    # Note: email is the unique property
    matching_node = Student.nodes.filter(email=student_data.get('email'))

    if matching_node:
        return Response({'info': 'student with given email already exists.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # Create and store a salted hash of the given password
    ph = PasswordHasher()
    student_data['password'] = ph.hash(student_data.get('password'))

    # convert dob from string back a datetime object
    student_data['dob'] = datetime.strptime(
        student_data.get('dob'), "%d-%m-%Y")

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

    student_node = Student.nodes.get(email=login_data.get('email'))

    # Check if student node exists
    if student_node is None:
        return Response({'info': 'student with given email doesnt not exist.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # Check credentials
    if check_credentials(student_node.password, login_data.get('password')):
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
def get_all_students(request):
    students = Student.nodes.all()
    serializer = StudentSerializer(students, many=True)
    return Response(serializer.data)


@api_view(['GET'])
def get_session_student(request):
    data = request.data
    try:
        # TODO: Just get the student of the session!!!
        student = Student.nodes.get(email=data.get('email'))
        serializer = StudentSerializer(student)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Student.DoesNotExist:
        return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['PUT'])
def change_session_student(request):
    data = request.data
    try:
        # TODO: Just get the student of the session!!!
        student = Student.nodes.get(email=data.get('old_email'))
    except Student.DoesNotExist:
        return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)

    # huge if block to check which attributes are requested to be changed:
    if data.get("forename") is not None and data.get("surname") is not None:
        student.forename = data.get('forename')
        student.surname = data.get('surname')
    if data.get("dob") is not None:
        student.dob = data.get('dob')
    if data.get("new_email") is not None:
        student.email = data.get('new_email')
    if data.get("password") is not None:
        student.password = data.get('password')
    if data.get("bio") is not None:
        student.bio = data.get('bio')
    # TODO: when the uniname changes, the zipcode should be updated as well @daniel
    if data.get("uni_name") is not None and data.get("degree") is not None and data.get("semester") is not None:
        student.uni_name = data.get('uni_name')
        student.degree = data.get('degree')
        student.semester = data.get('semester')
    if data.get("profile_picture") is not None:
        student.profile_picture = data.get('profile_picture')
    # if data.get("zip_code") is not None:
    #     student.zip_code = data.get('zip_code')
    if data.get("interests_and_goals") is not None:
        student.interests_and_goals = data.get('interests_and_goals')

    student.save()
    return Response({'info': 'successfully changed student.'}, status=status.HTTP_200_OK)


@api_view(['DELETE'])
def delete_session_student(request):
    request_data = request.data
    # TODO: Delete Sessionholder!
    try:
        student = Student.nodes.get(email=request_data.get('email'))
        student.delete()
        return Response({'info': 'successfully deleted student.'}, status=status.HTTP_200_OK)
    except Student.DoesNotExist:
        return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)


# TODO define a view for simple student matching algorithm

# ------------------STUDENT-END------------------#
# ------------------ADGROUP------------------#

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
        existing_ad_group = Ad_Group.nodes.get(name=data.get('name'))
    except Ad_Group.DoesNotExist:
        existing_ad_group = None

    if existing_ad_group:
        return Response({'error': 'An ad group with this name already exists.'}, status=status.HTTP_400_BAD_REQUEST)

    if data.get('name') is None or data.get('description') is None:
        return Response({'error': 'Please provide a name and a description for the ad group.'}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data.get('name')) or check_profanity(data.get('description')):
        return Response({'error': 'Please provide a name and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
    # Create a new ad group
    # TODO: validate payload!
    # TODO: connect the session holder student as the creator of the ad group
    # admin= Student.nodes.get(data['sessionholder']))?? bzw TODO: decode den Sessiontoken!
    ad_group = Ad_Group(name=data.get('name'),
                        description=data.get('description'))
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
        ad_group = Ad_Group.nodes.get(name=data.get('old_name'))
    except Ad_Group.DoesNotExist:
        return Response({'error': 'An ad group with this name does not exist. (please provide an old_name parameter)'}, status=status.HTTP_400_BAD_REQUEST)

    # TODO: check if session holder is the admin of the ad group!!

    if data.get('new_name') is None and data.get('description') is None:
        return Response({'error': 'Please provide a name or a description for the ad group.'}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data.get('new_name')) or check_profanity(data.get('description')):
        return Response({'error': 'Please provide a name and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)

    # if block to check which attributes are requested to be changed:
    if data.get("new_name") is not None:
        ad_group.name = data.get('new_name')
    if data.get("description") is not None:
        ad_group.description = data.get('description')
    ad_group.save()
    return Response({'info': 'successfully changed ad group.'}, status=status.HTTP_200_OK)


@api_view(['DELETE'])
def delete_ad_group(request):
    data = request.data
    # TODO: Check if sessionHolder is the admin of the ad group
    try:
        ad_group = Ad_Group.nodes.get(name=data.get('name'))
        ad_group.delete()
        return Response({'info': 'successfully deleted ad group and all of its ads.'}, status=status.HTTP_200_OK)
    except Ad_Group.DoesNotExist:
        return Response({'error': 'An ad group with this name does not exist. (please provide a name parameter)'}, status=status.HTTP_400_BAD_REQUEST)

# ------------------ADGROUP-END------------------#

# ------------------AD------------------#

# needs to get the name of the ad group (ad_group_name) as a parameter in the request!


@api_view(['POST'])
def get_ads_of_group(request):
    data = request.data
    # extract the ad group name from the request
    ad_group_name = data.get('ad_group_name')
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
    ad_group_name = data.get('ad_group_name')
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    if data.get("title") is None or data.get("description") is None:
        return Response({"info": "please provide title and description for the ad"}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data.get('title')) or check_profanity(data.get('description')):
        return Response({'error': 'Please provide a title and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)
        # create and save the ad
        # TODO: connect the session holder student as the admin of the ad group
        ad = Ad(title=data.get("title"),
                description=data.get("description"), image=data.get("image"))
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
    ad_group_name = data.get('ad_group_name')
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    if data.get("new_title") is None and data.get("description") is None:
        return Response({"info": "please provide a title or description for the ad"}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data.get('title')) or check_profanity(data.get('description')):
        return Response({'error': 'Please provide a title and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)

    try:
        # get the ad
        ad = ad_group.ads.get(title=data.get('old_title'))
        # change the ad
        # if block to check which attributes are requested to be changed:
        if data.get("new_title") is not None:
            ad.title = data.get('new_title')
        if data.get("description") is not None:
            ad.description = data.get('description')
        if data.get("image") is not None:
            ad.image = data.get('image')
        ad.save()
        return Response({'info': 'successfully changed ad.'}, status=status.HTTP_200_OK)
    except Ad.DoesNotExist:
        return Response({'error': 'Ad not found in the given group'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['DELETE'])
def delete_ad_in_group(request):
    data = request.data
    # extract the ad group name from the request
    # TODO: Check if sessionHolder is the admin of the ad
    ad_group_name = data.get('ad_group_name')
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)
    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)

    try:
        # get the ad
        ad = ad_group.ads.get(title=data.get('title'))
        ad.delete()
        return Response({'info': 'successfully deleted ad.'}, status=status.HTTP_200_OK)
    except Ad.DoesNotExist:
        return Response({'error': 'Ad not found in the given group'}, status=status.HTTP_404_NOT_FOUND)

# ------------------AD-END------------------#
