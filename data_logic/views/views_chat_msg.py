
"""
This module contains the views for sending and receiving chat messages.

The views in this module handle the logic for sending and receiving chat messages
between students. It includes functions for sending a chat message and pulling
new chat messages for a specific student.

Functions:
- send_chat_msg: Sends a chat message from one student to another.
- pull_new_chat_msg: Retrieves new chat messages for a specific student.

"""
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import json

from datetime import datetime, timedelta

from data_logic.models import *


@api_view(['POST'])
def send_chat_msg(request):
    """
    Sends a chat message.

    Args:
        request: The HTTP request object.

    Returns:
        A Response object with information about the success of sending the message.

    Raises:
        None.
    """
    message = json.loads(request.body)

    # Check if payload is valid
    # Check if request is authorized via JWT and 'from' attribute

    # Check if to student exists also

    # Convert message timestamp from string back to a datetime object
    message['timestamp'] = datetime.strptime(message.get('timestamp'),
                                             "%d-%m-%Y %H:%M:%S")

    # Temporary save 'to' attribute for later node connection
    msg_to = message.get('to')
    # Remove 'to' attribute from message
    del message['to']

    # Create new message node and save
    new_message_node = Message(**message)
    new_message_node.save()

    # Add message to sender's message list
    to_student = Student.nodes.get(email=msg_to)
    to_student.incoming_chat_messages.connect(new_message_node)

    return Response({'info': 'Successfully sent message.'},
                    status=status.HTTP_200_OK)


@api_view(['GET'])
def pull_new_chat_msg(request):
    """
    Retrieves new chat messages for a given student.

    Args:
        request (HttpRequest): The HTTP request object.

    Returns:
        Response: The HTTP response object containing the retrieved chat messages.

    Raises:
        None
    """
    # Get the student node who is requesting his messages
    student = Student.nodes.get(email=request.GET.get('email', None))

    if student is None:
        return Response({'info': 'student with given email doesnt not exist.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # Get the message nodes from the incoming_chat_messages relationship
    messages = student.incoming_chat_messages.all()

    messages_dict = [msg.to_dict() for msg in messages]

    # Delete messages from incoming_chat_messages
    for msg in messages:
        student.incoming_chat_messages.disconnect(msg)
        msg.delete()

    return Response({'messages': messages_dict},
                    status=status.HTTP_200_OK)
