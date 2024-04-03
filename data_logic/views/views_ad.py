# You need to create this serializer
from data_logic.serializers import AdSerializer
from data_logic.models import Ad
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import AuthenticationFailed

import json

from argon2 import PasswordHasher, exceptions

from data_logic.util import check_credentials, check_profanity

import jwt

from datetime import datetime, timedelta

from data_logic.models import Student, Ad_Group, Ad

from data_logic.serializers import StudentSerializer, AdGroupSerializer, AdSerializer

from data_logic.util import create_jwt, decode_jwt

from data_logic.ptrie_structures import student_ptrie, ads_ptrie

# Create your views here.


@api_view(['POST'])
def test_relationship(request):
    ad_name = request.data.get('ad_name')
    try:
        ad = Ad.nodes.get(title=ad_name)
        # ad_group1 = ad.ad_group
        string1 = ad.ad_group[0].name
        return (Response({'info': 'test successful.', 'ad_group': string1}, status=status.HTTP_200_OK))
    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)
# ------------------ADGROUP------------------#


@api_view(['GET'])
def get_ad_groups(request):
    ad_groups = Ad_Group.nodes.all()
    serializer = AdGroupSerializer(ad_groups, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
def create_ad_group(request):
    data = request.data

    # Check if an ad group with the provided name already exists
    # try catch block to handle the case where the ad group does not exist
    try:
        existing_ad_group = Ad_Group.nodes.get(name=data.get('name'))
    except Ad_Group.DoesNotExist:
        existing_ad_group = None

    if existing_ad_group:
        return Response({'error': 'An ad group with this name already exists.'}, status=status.HTTP_400_BAD_REQUEST)

    if data.get('name') is None or data.get('description') is None:
        return Response({'error': 'Please provide a name and a description for the ad group.'}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data.get('name')) or check_profanity(data.get('description')):
        return Response({'error': 'Please provide a name and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
    # get the student from the jwt token
    try:
        student = decode_jwt(request)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)
    # Create a new ad group
    ad_group = Ad_Group(name=data.get('name'),
                        description=data.get('description'))
    ad_group.save()

    # Save Ad Group to the ptrie for efficient lookup
    ads_ptrie.add_ad_group(ad_group)

    # connect sessionholder as admin of the ad group
    ad_group.admin.connect(student)
    # Serialize the new ad group
    serializer = AdGroupSerializer(ad_group)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['PUT'])
def change_ad_group(request):
    data = request.data
    # Check if an ad group with the provided name already exists
    # try catch block to handle the case where the ad group does not exist
    try:
        ad_group = Ad_Group.nodes.get(name=data.get('old_name'))
    except Ad_Group.DoesNotExist:
        return Response({'error': 'An ad group with this name does not exist. (please provide an old_name parameter)'}, status=status.HTTP_400_BAD_REQUEST)

    # Remove the old ad group from the ptrie
    ads_ptrie.remove_ad_group(ad_group)

    # check if session holder is the admin of the ad group
    try:
        student = decode_jwt(request)
        if not ad_group.admin.is_connected(student):
            return Response({'error': 'You are not the admin of this ad group.'}, status=status.HTTP_403_FORBIDDEN)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

    if data.get('new_name') is None and data.get('description') is None:
        return Response({'error': 'Please provide a name or a description for the ad group.'}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data.get('new_name')) or check_profanity(data.get('description')):
        return Response({'error': 'Please provide a name and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)

    # if block to check which attributes are requested to be changed:
    if data.get("new_name") is not None:
        ad_group.name = data.get('new_name')
    # change all of the other attributes, which are requested
    for key, value in data.items():
        if hasattr(ad_group, key):
            setattr(ad_group, key, value)
    ad_group.save()

    # Re add the ad group to the ptrie
    ads_ptrie.add_ad_group(ad_group)

    return Response({'info': 'successfully changed ad group.'}, status=status.HTTP_200_OK)


@api_view(['DELETE'])
def delete_ad_group(request):
    data = request.data
    # Check if sessionHolder is the admin of the ad group
    try:
        student = decode_jwt(request)
        if not ad_group.admin.is_connected(student):
            return Response({'error': 'You are not the admin of this ad group.'}, status=status.HTTP_403_FORBIDDEN)
    except Student.DoesNotExist:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)
    try:
        ad_group = Ad_Group.nodes.get(name=data.get('name'))
        ad_group.delete()

        # Remove the ad group from the ptrie
        ads_ptrie.remove_ad_group(ad_group)

        return Response({'info': 'successfully deleted ad group and all of its ads.'}, status=status.HTTP_200_OK)
    except Ad_Group.DoesNotExist:
        return Response({'error': 'An ad group with this name does not exist. (please provide a name parameter)'}, status=status.HTTP_400_BAD_REQUEST)

# ------------------ADGROUP-END------------------#

# ------------------AD------------------#

# needs to get the name of the ad group (ad_group_name) as a parameter in the request!


@api_view(['POST'])
def get_ads_of_group(request):
    data = request.data
    # extract the ad group name from the request
    ad_group_name = data.get('ad_group_name')
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)
        # get all ads of the ad group
        ads = ad_group.ads.all()
        # Serialize the queryset
        serializer = AdSerializer(ads, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
def create_ads_in_group(request):
    data = request.data
    # extract the ad group name from the request
    ad_group_name = data.get('ad_group_name')
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    if data.get("title") is None or data.get("description") is None:
        return Response({"info": "please provide title and description for the ad"}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data.get('title')) or check_profanity(data.get('description')):
        return Response({'error': 'Please provide a title and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)

        try:
            student = decode_jwt(request)
        except Student.DoesNotExist:
            return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

        # create and save the ad
        ad = Ad(title=data.get("title"),
                description=data.get("description"), image=data.get("image"))
        ad.save()

        # Add new ad to the ptrie for efficient lookup
        ads_ptrie.add_ad(ad)

        # connect the ad to the ad group
        ad_group.ads.connect(ad)
        # connect the session holder student as the admin of the ad group
        ad.admin.connect(student)

        return Response({'info': f'successfully created ad in {ad_group_name}.'},
                        status=status.HTTP_200_OK)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['PUT'])
def change_ad_in_group(request):
    data = request.data
    # extract the ad group name from the request
    ad_group_name = data.get('ad_group_name')
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    if check_profanity(data.get('title')) or check_profanity(data.get('description')):
        return Response({'error': 'Please provide a title and a description without profanity.'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)

    try:
        # get the ad
        ad = ad_group.ads.get(title=data.get('old_title'))

        # Remove the old ad from the ptrie
        ads_ptrie.remove_ad(ad)

        # Check if sessionHolder is the admin of the ad
        try:
            student = decode_jwt(request)
            if not ad.admin.is_connected(student):
                return Response({'error': 'You are not the admin of this ad.'}, status=status.HTTP_403_FORBIDDEN)
        except Student.DoesNotExist:
            return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)
        # change the ad
        # if block to change the title if requested
        # (the new_title is not an standard attribute of the ad model, so it needs to be handled separately)
        if data.get("new_title") is not None:
            ad.title = data.get('new_title')
        # change all of the other attributes, which are requested
        for key, value in data.items():
            if hasattr(ad, key):
                setattr(ad, key, value)
        ad.save()

        # Re add the ad to the ptrie
        ads_ptrie.add_ad(ad)

        return Response({'info': 'successfully changed ad.'}, status=status.HTTP_200_OK)
    except Ad.DoesNotExist:
        return Response({'error': 'Ad not found in the given group'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['DELETE'])
def delete_ad_in_group(request):
    data = request.data
    # extract the ad group name from the request
    # TODO: Check if sessionHolder is the admin of the ad
    ad_group_name = data.get('ad_group_name')
    if ad_group_name is None:
        return Response({"info": "please post the ad group name as the parameter ad_group_name"}, status=status.HTTP_400_BAD_REQUEST)
    try:
        # get the ad group
        ad_group = Ad_Group.nodes.get(name=ad_group_name)
    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)

    try:
        # get the ad
        ad = ad_group.ads.get(title=data.get('title'))
        # Check if sessionHolder is the admin of the ad
        try:
            student = decode_jwt(request)
            if not ad.admin.is_connected(student):
                return Response({'error': 'You are not the admin of this ad.'}, status=status.HTTP_403_FORBIDDEN)
        except Student.DoesNotExist:
            return Response({'error': ' Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

        ad.delete()

        # Delete the ad from the ptrie
        ads_ptrie.remove_ad(ad)

        return Response({'info': 'successfully deleted ad.'}, status=status.HTTP_200_OK)
    except Ad.DoesNotExist:
        return Response({'error': 'Ad not found in the given group'}, status=status.HTTP_404_NOT_FOUND)

# ------------------AD-END------------------#

# -------------------Search------------------#


@api_view(['POST'])
def query_ads(request):
    # Check if the session student exists
    if decode_jwt(request) is None:
        return Response({'error': 'Session Student not found'}, status=status.HTTP_404_NOT_FOUND)

    # Extract the query string from the request
    query = request.data.get('query')

    if query is None:
        return Response({"info": "Please provide a query string as the query parameter"},
                        status=status.HTTP_400_BAD_REQUEST)

    # Search matches in the ads ptrie
    matching_ads = ads_ptrie.search(query)
    # Extract the ads from the ptrie (ptrie also contains ad groups, so we need to filter the ads out)
    matching_ads = [ad for ad in matching_ads if type(ad) is Ad]

    # Serialize the queryset
    serializer = AdSerializer(matching_ads, many=True)

    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
def query_ads_by_group(request):
    data = request.data
    query = data.get('query')
    ad_group_name = data.get('ad_group_name')

    if query is None or ad_group_name is None:
        return Response({"info": "please post the search string as the parameter query and the ad group name as the parameter ad_group_name"},
                        status=status.HTTP_400_BAD_REQUEST)
    try:
        # Search matches in the ads ptrie
        matching_ads = ads_ptrie.search(query, ad_group_name)

        # Serialize the queryset
        serializer = AdSerializer(matching_ads, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)

    except Ad_Group.DoesNotExist:
        return Response({'error': 'Ad group not found'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
def query_ad_groups(request):
    data = request.data
    query = data.get('query')

    if query is None:
        return Response({"info": "please post the search string as the parameter query"}, status=status.HTTP_400_BAD_REQUEST)

    # Search matches in the ads ptrie
    matching_ad_groups = ads_ptrie.search(query)
    # Extract the ad groups from the ptrie (ptrie also contains ads, so we need to filter the ad groups out)
    matching_ad_groups = [
        ad_group for ad_group in matching_ad_groups if type(ad_group) is Ad_Group]

    serializer = AdGroupSerializer(matching_ad_groups, many=True)

    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
def query_all(request):
    query = request.data.get('query')

    if query is None:
        return Response({"info": "please post the search string as the parameter query"}, status=status.HTTP_400_BAD_REQUEST)

    matching_students = student_ptrie.search(query)
    matching_ads_and_grops = ads_ptrie.search(query)

    # Extract ads and ad groups
    matching_ads = [ad for ad in matching_ads_and_grops if type(ad) is Ad]
    matching_ad_groups = [
        ad_group for ad_group in matching_ads_and_grops if type(ad_group) is Ad_Group]

    # Serialize the queryset
    student_serializer = StudentSerializer(matching_students, many=True)
    ad_serializer = AdSerializer(matching_ads, many=True)
    ad_group_serializer = AdGroupSerializer(matching_ad_groups, many=True)

    return Response({'students': student_serializer.data, 'ad_groups': ad_group_serializer.data, 'ads': ad_serializer.data}, status=status.HTTP_200_OK)

# -------------------Search-END------------------#
