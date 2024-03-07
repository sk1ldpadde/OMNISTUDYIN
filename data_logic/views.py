from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import json

import argon2

import jwt

import os

import hashlib

from datetime import datetime, timedelta

from data_logic.models import Student

# Create your views here.

# easy test view for debugging
@api_view(['GET'])
def get_value(request):
    matching = Student.nodes.filter(email='inf22111@lehre.dhbw-stuttgart.de').first()
    return Response({'value': matching.semester})

@api_view(['POST'])
def register_student(request):
    student_data = json.loads(request.body)

    # check if payload is valid

    # check if user does not already exist
    # note: email is the unique property

    matching_node = Student.nodes.filter(email=student_data)

    if matching_node:
        return Response({'info': 'student with given email already exists.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # generate a random salt
    salt = os.urandom(32)

    # assign salt to student data
    student_data['salt'] = salt.hex()
    
    hash_object = hashlib.sha256()
    hash_object.update(student_data['password'].encode())

    # Get the hexadecimal representation of the hash
    student_data['password'] = hash_object.hexdigest()
    
    # convert dob from string back to datetime object
    student_data['dob'] = datetime.strptime(student_data['dob'], "%d-%m-%Y")

    # replace the given "easy" hash with the random salted argon2i hash
    # student_data['password'] = compute_argon2i_hash(student_data['password'], student_data['salt'])

    # create new user and save
    new_student_node = Student(**student_data)
    new_student_node.save()

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
