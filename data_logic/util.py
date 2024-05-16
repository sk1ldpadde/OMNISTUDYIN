
"""
This module contains utility functions for data logic operations.

Functions:
- compute_current_age(student: Student) -> int: Computes the current age of a student based on their date of birth.
- check_credentials(stored_pwd: str, request_pwd: str) -> bool: Checks if the provided password matches the stored password hash.
- check_profanity(string: str) -> bool: Checks if a given string contains profanity.
- create_jwt(student: Student) -> str: Creates a JSON Web Token (JWT) for the given student.
- decode_jwt(request) -> Student: Decodes a JSON Web Token (JWT) from the request headers and returns the corresponding student object.
"""


from data_logic.models import *

from datetime import date
from datetime import datetime, timedelta

from argon2 import PasswordHasher, exceptions

from better_profanity import profanity

import jwt

from rest_framework.exceptions import AuthenticationFailed

from data_logic.secret import SECRET_KEY


def compute_current_age(student: Student):
    """
    Computes the current age of a student based on their date of birth.

    Args:
        student (Student): The student object containing the date of birth.

    Returns:
        int: The current age of the student.
    """
    today = date.today()
    student_dob = datetime.strptime(
        student.dob.strftime('%d-%m-%Y'), "%d-%m-%Y")

    age = today.year - student_dob.year

    # check if birthday already happened this year
    if (today.month, today.day) < (student_dob.month, student_dob.day):
        age -= 1

    return age


# Check if the given password matches the stored salted hash
def check_credentials(stored_pwd, request_pwd):
    """
    Checks if the provided password matches the stored password hash.

    Parameters:
    stored_pwd (str): The stored password hash.
    request_pwd (str): The password provided for verification.

    Returns:
    bool: True if the password matches the hash, False otherwise.
    """
    ph = PasswordHasher()
    try:
        ph.verify(stored_pwd, request_pwd)
        return True
    except exceptions.VerifyMismatchError:
        # The password does not match the hash
        return False


def check_profanity(string: str):
    """
    Check if a given string contains profanity.

    Args:
        string (str): The string to be checked for profanity.

    Returns:
        bool: True if the string contains profanity, False otherwise.
    """
    if string is None:
        return False
    return profanity.contains_profanity(string)


# Create a new jwt token for the given student
def create_jwt(student: Student):
    """
    Creates a JSON Web Token (JWT) for the given student.

    Parameters:
        student (Student): The student object for which the JWT is created.

    Returns:
        str: The encoded JWT.

    """
    jwt_payload = {
        'sub': student.email,
        'exp': datetime.now() + timedelta(hours=10)  # Token expiration time
    }
    return jwt.encode(jwt_payload, SECRET_KEY, algorithm='HS256')

# Decode the jwt and return the student object


def decode_jwt(request):
    """
    Decode a JSON Web Token (JWT) from the request headers and return the corresponding student object.

    Parameters:
    - request: The HTTP request object containing the JWT in the headers.

    Returns:
    - The student object associated with the JWT payload.

    Raises:
    - AuthenticationFailed: If the token is expired or invalid.
    - Student.DoesNotExist: If the student does not exist in the database.
    """

    token = request.headers.get('Authorization')

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        print(payload)
    except jwt.ExpiredSignatureError:
        raise AuthenticationFailed('Token expired')
    except jwt.InvalidTokenError:
        raise AuthenticationFailed('Invalid token')

    try:
        return Student.nodes.get(email=payload['sub'])
    except Student.DoesNotExist:
        raise Student.DoesNotExist
