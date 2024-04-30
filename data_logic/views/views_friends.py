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


@api_view(['GET'])
def get_friends(request):
    """
    Retrieves the list of friends for a given student.

    Parameters:
    - request: The HTTP request object.

    Returns:
    - Response: The HTTP response object containing the list of friends and their friendship status.
    """

    try:
        student = decode_jwt(request)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

    matching = student.friends.all()
    print(matching)

    serializer = StudentSerializer(matching, many=True)
    serializer_data = serializer.data
    for friend in matching:
        print(friend.friends.all())
        if student not in friend.friends.all():
            for f in serializer_data:
                if f["email"] == friend.email:
                    f["friendship_status"] = "pending"
        elif student in friend.friends.all():
            for f in serializer_data:
                if f["email"] == friend.email:
                    f["friendship_status"] = "accepted"
        else:
            for f in serializer_data:
                if f["email"] == friend.email:
                    f["friendship_status"] = "unknown"
    return Response(serializer_data, status=status.HTTP_200_OK)


@api_view(['POST'])
def send_friend_request(request):
    """
    Sends a friend request from the current student to another student.

    Parameters:
    - request: The HTTP request object.

    Returns:
    - If the friend request is sent successfully, returns a Response object with a success message and status code 200.
    - If the session student is not found, returns a Response object with an error message and status code 404.
    - If the friend ID is not provided, returns a Response object with an error message and status code 400.
    - If the friend is not found, returns a Response object with an error message and status code 404.
    - If the friend already exists in the student's friends list, returns a Response object with an error message and status code 400.
    """

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
    """
    Accepts a friend request from another student.

    Parameters:
    - request: The HTTP request object.

    Returns:
    - If the friend request is accepted successfully, returns a response with status code 200 and a success message.
    - If the session student is not found, returns a response with status code 404 and an error message.
    - If the friend ID is not provided, returns a response with status code 400 and an error message.
    - If the friend is not found, returns a response with status code 404 and an error message.
    - If the friend request is not found, returns a response with status code 400 and an error message.
    """

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


@api_view(["POST"])
def delete_friend(request):
    """
    Deletes a friend from the student's friend list.

    Args:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The HTTP response object indicating the success or failure of the operation.
    """

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

    student.friends.disconnect(friend)
    friend.friends.disconnect(student)
    friend.save()
    student.save()
    return Response({'success': 'Friend deleted'}, status=status.HTTP_200_OK)


# Findfriends IN PROGRESS
# TODO: Implement the find_friends function
@api_view(['GET'])
def find_friends(request):
    try:
        student = decode_jwt(request)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

    matching = Student.nodes.all()  # currently only returning all existing students
    serializer = StudentSerializer(matching, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)
