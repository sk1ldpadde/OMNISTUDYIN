from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

import json

from datetime import datetime, timedelta

from data_logic.models import *


@api_view(['POST'])
def send_chat_msg(request):
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
    # Get the student node who is requesting his messages
    student = Student.nodes.get(email=request.GET.get('email', None))

    if student is None:
        return Response({'info': 'student with given email doesnt not exist.'},
                        status=status.HTTP_400_BAD_REQUEST)

    # Get the message nodes from the incoming_chat_messages relationship
    messages = student.incoming_chat_messages.all()

    messages_dict = [msg.to_dict() for msg in messages]

    # delete messages from incoming_chat_messages
    for msg in messages:
        student.incoming_chat_messages.disconnect(msg)
        msg.delete()

    return Response({'messages': messages_dict},
                    status=status.HTTP_200_OK)
