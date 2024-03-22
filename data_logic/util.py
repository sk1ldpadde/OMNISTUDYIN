from data_logic.models import *

from datetime import date
from datetime import datetime, timedelta

from argon2 import PasswordHasher, exceptions

from better_profanity import profanity

import jwt

from rest_framework.exceptions import AuthenticationFailed

# TODO Find a way to store the secret key
SECRET_KEY = "12345"


# TODO write tests to validate function

def compute_current_age(student: Student):
    today = date.today()
    student_dob = datetime.strptime(student.dob, "%d-%m-%Y")

    age = today.year - student_dob.year

    # check if birthday already happend this year
    if (today.month, today.day) < (student_dob.month, student_dob.day):
        age -= 1

    return age


# Check if the given password matches the stored salted hash
def check_credentials(stored_pwd, request_pwd):
    ph = PasswordHasher()
    try:
        ph.verify(stored_pwd, request_pwd)
        return True
    except exceptions.VerifyMismatchError:
        # The password does not match the hash
        return False


def check_profanity(string: str):
    if string is None:
        return False
    return profanity.contains_profanity(string)


# Create a new jwt token for the given student
def create_jwt(student: Student):
    jwt_payload = {
        'sub': student.email,
        'exp': datetime.now() + timedelta(hours=10)  # Token expiration time
    }
    return jwt.encode(jwt_payload, SECRET_KEY, algorithm='HS256')

# decode the jwt and return the student object


def decode_jwt(request):
    token = request.headers.get('Authorization')

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        print(payload)
    except jwt.ExpiredSignatureError:
        raise AuthenticationFailed('Token expired')
    except jwt.InvalidTokenError:
        raise AuthenticationFailed('Invalid token')

    try:
        return Student.nodes.get(
            email=payload['sub'])
    except Student.DoesNotExist:
        raise Student.DoesNotExist
