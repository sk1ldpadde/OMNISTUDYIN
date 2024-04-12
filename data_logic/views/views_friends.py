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


@api_view(['POST'])
def get_friends(request):
    try:
        student = decode_jwt(request)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

    matching = student.friends.all()
    serializer = StudentSerializer(matching, many=True)
    serializer_data = serializer.data
    for friend in matching:
        if student not in friend.friends.all():
            for f in serializer_data:
                f["friendship_status"] = "pending"
        else:
            for f in serializer_data:
                f["friendship_status"] = "accepted"
    return Response(serializer_data, status=status.HTTP_200_OK)


@api_view(['POST'])
def send_friend_request(request):
    try:
        student = decode_jwt(request)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

    try:
        friend_id = request.data.get('friend_email')
    except KeyError:
        return Response({'error': 'Friend ID not provided'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        friend = Student.nodes.get(email=friend_id)
    except Student.DoesNotExist:
        return Response({'error': 'Friend not found'}, status=status.HTTP_404_NOT_FOUND)

    if friend in student.friends.all():
        return Response({'error': 'Friend already exists'}, status=status.HTTP_400_BAD_REQUEST)

    student.friends.connect(friend)
    student.save()
    return Response({'success': 'Friend request sent'}, status=status.HTTP_200_OK)


@api_view(['POST'])
def accept_friend_request(request):
    try:
        student = decode_jwt(request)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

    try:
        friend_id = request.data.get('friend_email')
    except KeyError:
        return Response({'error': 'Friend ID not provided'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        friend = Student.nodes.get(email=friend_id)
    except Student.DoesNotExist:
        return Response({'error': 'Friend not found'}, status=status.HTTP_404_NOT_FOUND)

    if student not in friend.friends.all():
        return Response({'error': 'Friend request not found'}, status=status.HTTP_400_BAD_REQUEST)

    student.friends.connect(friend)
    student.save()
    return Response({'success': 'Friend request accepted'}, status=status.HTTP_200_OK)
