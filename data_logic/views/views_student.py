from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import AuthenticationFailed

import json

from argon2 import PasswordHasher, exceptions

from data_logic.util import check_credentials, check_profanity

import jwt

from datetime import datetime, timedelta

from data_logic.models import Student

from data_logic.serializers import StudentSerializer

from data_logic.util import create_jwt, decode_jwt

from data_logic.ptrie_structures import student_ptrie

from data_logic.secret import SECRET_KEY

# Create your views here.

# easy test view for debugging

# ------------------TEST------------------#


@api_view(['GET'])
def get_value(request):
    token = request.headers.get('Authorization')

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        print(payload)
    except jwt.ExpiredSignatureError:
        raise AuthenticationFailed('Token expired')
    except jwt.InvalidTokenError:
        raise AuthenticationFailed('Invalid token')

    matching = Student.nodes.filter(
        email=payload['sub']).first()
    return Response({'forename': matching.forename, 'semester': matching.semester})


@api_view(['GET'])
def test(request):
    return Response({'info': 'test successful.'},
                    status=status.HTTP_200_OK)

# ------------------TEST-END------------------#

# ------------------JWT-----------------------#


@api_view(['GET'])
def update_jwt(request):
    # use given token to authorize the user
    token = request.headers.get('Authorization')
    # which user to create the token for
    email = request.data.get('email')

    try:
        payload = jwt.decode(token, "12345", algorithms=['HS256'])
    except jwt.ExpiredSignatureError:
        # if the token is expired, the student needs to log in again
        raise AuthenticationFailed('Token expired')
    except jwt.InvalidTokenError:
        raise AuthenticationFailed('Invalid token')

    if payload['sub'] != email or not Student.nodes.filter(email=email):
        raise AuthenticationFailed('Invalid token or email.')

    # generate a new token
    jwt_token = create_jwt(Student.nodes.get(email=email))

    return Response({'jwt': jwt_token}, status=status.HTTP_200_OK)

# ------------------JWT-END-------------------#

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

    # Convert dob from string back to a datetime object
    student_data['dob'] = datetime.strptime(
        student_data.get('dob'), "%d-%m-%Y")

    # Create new user and save
    new_student_node = Student(**student_data)
    new_student_node.save()

    # Add new student to the ptrie for efficient lookup
    student_ptrie.add_student(new_student_node)

    # Return success
    return Response({'info': 'Successfully registered new student.'},
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
        jwt_token = create_jwt(student_node)

        return Response({'info': 'login successful.', 'jwt': jwt_token},
                        status=status.HTTP_200_OK)
    else:
        return Response({'info': 'login attempt failed. wrong credentials.'},
                        status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
def get_all_students(request):
    students = Student.nodes.all()
    serializer = StudentSerializer(students, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['GET'])
def get_session_student(request):
    try:
        student = decode_jwt(request)
        serializer = StudentSerializer(student)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['PUT'])
def change_session_student(request):
    data = request.data

    try:
        student = decode_jwt(request)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)
    
    # Remove student from the ptrie during the update
    student_ptrie.remove_student(student)

    for key, value in data.items():
        if hasattr(student, key):
            setattr(student, key, value)
    student.save()
    
    # Re add student to the ptrie
    student_ptrie.add_student(student)
    
    return Response({'info': 'successfully changed student.'}, status=status.HTTP_200_OK)


@api_view(['DELETE'])
def delete_session_student(request):
    try:
        student = decode_jwt(request)
        student.delete()

        # Remove student from the ptrie
        student_ptrie.remove_student(student)
        return Response({'info': 'successfully deleted student.'}, status=status.HTTP_200_OK)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
def query_students(request):
    # Check if the session student exists
    if decode_jwt(request) is None:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

    # Extract the query string from the request
    query = request.data.get('query')

    if query is None:
        return Response({"info": "Please provide a query string as the query parameter"},
                        status=status.HTTP_400_BAD_REQUEST)

    # Search matches in the student ptrie
    matching_students = student_ptrie.search(query)

    # Serialize the queryset
    serializer = StudentSerializer(matching_students, many=True)

    return Response(serializer.data, status=status.HTTP_200_OK)


# TODO: define a view for session password or email changes
# TODO define a view for simple student matching algorithm

# ------------------STUDENT-END------------------#
