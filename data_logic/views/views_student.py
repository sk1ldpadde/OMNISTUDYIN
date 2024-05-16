

"""
This module contains views for handling student-related operations in the data logic application.

The views in this module include:
- `get_value`: Retrieves the value of a student's forename and semester based on the provided token.
- `test`: Used to test the functionality of the API endpoint.
- `update_jwt`: Updates the JSON Web Token (JWT) for the authenticated user.
- `register_student`: Registers a new student.
- `login_student`: Authenticates a student's login credentials and generates a JWT token if the credentials are correct.
- `get_all_students`: Retrieves all students from the database and serializes them using the StudentSerializer.
- `get_session_student`: Retrieves the session student based on the provided request.
- `change_session_student`: Changes the session student's attributes based on the provided data.
- `delete_session_student`: Deletes the session student.
- `query_students`: Retrieves a list of students based on the provided query string.
"""
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

# Easy test view for debugging

# ------------------TEST------------------#


@api_view(['GET'])
def get_value(request):
    """
    Retrieves the value of a student's forename and semester based on the provided token.

    Args:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The HTTP response object containing the student's forename and semester.

    Raises:
        AuthenticationFailed: If the token is expired or invalid.
    """
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
    """
    This function is used to test the functionality of the API endpoint.

    Parameters:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The response object containing the test result.
    """
    return Response({'info': 'test successful.'},
                    status=status.HTTP_200_OK)


# ------------------TEST-END------------------#

# ------------------JWT-----------------------#


@api_view(['GET'])
def update_jwt(request):
    """
    Updates the JSON Web Token (JWT) for the authenticated user.

    Parameters:
    - request: The HTTP request object.

    Returns:
    - Response: The HTTP response object containing the updated JWT.

    Raises:
    - AuthenticationFailed: If the token is expired, invalid, or the email is invalid.
    """

    # Use given token to authorize the user
    token = request.headers.get('Authorization')

    # Which user to create the token for
    email = request.data.get('email')

    try:
        payload = jwt.decode(token, "12345", algorithms=['HS256'])
    except jwt.ExpiredSignatureError:
        # If the token is expired, the student needs to log in again
        raise AuthenticationFailed('Token expired')
    except jwt.InvalidTokenError:
        raise AuthenticationFailed('Invalid token')

    if payload['sub'] != email or not Student.nodes.filter(email=email):
        raise AuthenticationFailed('Invalid token or email.')

    # Generate a new token
    jwt_token = create_jwt(Student.nodes.get(email=email))

    return Response({'jwt': jwt_token}, status=status.HTTP_200_OK)

# ------------------JWT-END-------------------#

# ------------------STUDENT------------------#


@api_view(['POST'])
def register_student(request):
    """
    Register a new student.

    Args:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The HTTP response object indicating the result of the registration.

    Raises:
        None

    """

    student_data = json.loads(request.body)

    # Check if payload is valid

    # Check if user does not already exist
    # Note: email is the unique property
    try:
        matching_node = Student.nodes.filter(email=student_data.get('email'))
    except Student.DoesNotExist:
        return Response({'info': 'student with given email doesnt not exist.'},
                        status=status.HTTP_400_BAD_REQUEST)

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


@ api_view(['POST'])
def login_student(request):
    """
    Authenticates a student's login credentials and generates a JWT token if the credentials are correct.

    Args:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The HTTP response object containing the login status and JWT token.

    Raises:
        None

    """

    login_data = json.loads(request.body)

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


@ api_view(['GET'])
def get_all_students(request):
    """
    Retrieve all students from the database and serialize them using the StudentSerializer.

    Parameters:
    - request: The HTTP request object.

    Returns:
    - A Response object containing the serialized data of all students.
    """
    students = Student.nodes.all()
    serializer = StudentSerializer(students, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@ api_view(['GET'])
def get_session_student(request):
    """
    Retrieves the session student based on the provided request.

    Parameters:
    - request: The HTTP request object.

    Returns:
    - If the session student is found, returns the serialized student data with a status code of 200.
    - If the session student is not found, returns an error message with a status code of 404.
    """
    try:
        student = decode_jwt(request)
        serializer = StudentSerializer(student)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)


@ api_view(['PUT'])
def change_session_student(request):
    """
    Change the session student's attributes based on the provided data.

    Args:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The HTTP response object indicating the status of the operation.
    """

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


@ api_view(['DELETE'])
def delete_session_student(request):
    """
    Deletes the session student.

    Args:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The HTTP response object.

    Raises:
        Student.DoesNotExist: If the session student does not exist.
    """
    try:
        student = decode_jwt(request)
        student.delete()

        # Remove student from the ptrie
        student_ptrie.remove_student(student)
        return Response({'info': 'successfully deleted student.'}, status=status.HTTP_200_OK)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)


@ api_view(['POST'])
def query_students(request):
    """
    Retrieves a list of students based on the provided query string.

    Args:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The HTTP response object containing the serialized list of matching students.

    Raises:
        NotFound (HTTP 404): If the session student is not found.
        BadRequest (HTTP 400): If the query string is not provided.

    """

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


# ------------------STUDENT-END------------------#
