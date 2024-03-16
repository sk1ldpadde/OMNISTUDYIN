from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import json

from argon2 import PasswordHasher, exceptions

from data_logic.util import check_credentials

import jwt

from datetime import datetime, timedelta

from data_logic.models import Student

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

    # Check if payload is valid
    pass

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
