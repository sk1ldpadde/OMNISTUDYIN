from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import json

import argon2

import jwt

from datetime import datetime, timedelta

from models import Student

# Create your views here.


@api_view(['POST'])
def register_student(request):
    student_data = json.loads(request.body)

    # check if payload is valid

    # check if user does not already exist
    # note: email is the unique property

    node = Student.nodes.get(email=student_data)

    if node is not None:
        return Response({'info': 'student with given email already exists.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # generate a random salt
    salt = argon2.low_level.ffi.new(
        "uint8_t[]", argon2.low_level.TypeID.Argon2i.SALTBYTES)
    argon2.low_level.fill_random_bytes(
        salt, argon2.low_level.TypeID.Argon2i.SALTBYTES)

    # assign salt to student data
    student_data['salt'] = salt.hex()

    # replace the given "easy" hash with the random salted argon2i hash
    student_data['password'] = compute_argon2i_hash(student_data['password'], student_data['salt'])

    # create new user and save
    new_student_node = Student.create(**student_data)

    # return success
    return Response({'info': 'successfully registered new student.'},
                    status=status.HTTP_200_OK)


@api_view(['POST'])
def login_student(request):
    login_data = json.loads(request.body)

    # check if payload is valid
    pass

    student_node = Student.nodes.get(email=login_data['email'])

    # check if student node exists
    if student_node is None:
        return Response({'info': 'student with given email doesnt not exist.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # check credentials
    if check_credentials(login_data['password'], student_node.salt, student_node.password):
        # credentials are correct, generate JWT
        jwt_payload = {
            'sub': student_node.student_id,
            'exp': datetime.now() + timedelta(days=1)  # Token expiration time
        }

        # TODO find a way to store the secret key
        jwt_token = jwt.encode(jwt_payload, None, algorithm='HS256')

        return Response({'info': 'login successfull.', 'jwt': jwt_token},
                        status=status.HTTP_200_OK)

    else:
        return Response({'info': 'login attempt failed. wrong credentials.'},
                        status=status.HTTP_400_BAD_REQUEST)


def check_credentials(user_pword_hash, salt, stored_result_hash):
    return stored_result_hash == compute_argon2i_hash(user_pword_hash, salt)


def compute_argon2i_hash(content, salt):
    # convert content and salt to bytes
    user_hashed_pword_bytes = bytes.fromhex(content)
    salt_bytes = bytes.fromhex(salt)

    return argon2.low_level.hash_secret(
        content, salt,
        time_cost=1, memory_cost=8, parallelism=1, hash_len=64, type=argon2.low_level.Type.D
    )


# TODO define a view for simple student matching algorithm
