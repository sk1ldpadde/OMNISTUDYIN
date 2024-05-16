"""
This module contains serializers for the models in the data_logic app.

The serializers are used to convert complex data types, such as querysets and model instances, into native Python datatypes that can be easily rendered into JSON, XML, or other content types. They also provide deserialization, allowing parsed data to be converted back into complex types, after first validating the incoming data.

The serializers in this module are:
- AdGroupSerializer: Serializer for the Ad_Group model.
- AdSerializer: Serializer for the Ad model.
- StudentSerializer: Serializer for the Student model.
- StudentFriendSerializer: Serializer for the StudentFriend model.

Each serializer defines fields that should be serialized/deserialized and provides methods for creating and updating instances of the corresponding models.

Note: The serializers assume that the corresponding models have methods to handle creation and updating of instances.
"""
from rest_framework import serializers
from .models import Ad_Group, Ad, Student

# Custom Serializers for the models


class AdGroupSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100)
    description = serializers.CharField()

    def create(self, validated_data):
        # Create and return a new `Ad_Group` instance, given the validated data
        # This assumes you have a method to handle this in your neomodel object
        return Ad_Group.create(**validated_data)

    def update(self, instance, validated_data):
        # Update and return an existing `Ad_Group` instance, given the validated data
        instance.name = validated_data.get('name', instance.name)
        instance.description = validated_data.get(
            'description', instance.description)
        instance.save()
        return instance


class AdSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200)
    description = serializers.CharField()
    image = serializers.CharField()  # Assuming image is stored as a base64 string

    def create(self, validated_data):
        # Use your model's method to create a new Ad instance
        return Ad.create(**validated_data)

    def update(self, instance, validated_data):
        # Update the Ad instance
        instance.title = validated_data.get('title', instance.title)
        instance.description = validated_data.get(
            'description', instance.description)
        instance.image = validated_data.get('image', instance.image)
        instance.save()
        return instance


class StudentSerializer(serializers.Serializer):
    forename = serializers.CharField(max_length=100)
    surname = serializers.CharField(max_length=100)
    email = serializers.EmailField()
    dob = serializers.DateTimeField()  # Adjust the field type if needed
    bio = serializers.CharField(allow_blank=True, required=False)
    uni_name = serializers.CharField(
        max_length=200, allow_blank=True, required=False)
    degree = serializers.CharField(
        max_length=200, allow_blank=True, required=False)
    semester = serializers.IntegerField(min_value=1, required=False)
    profile_picture = serializers.CharField()  # Assuming this is a base64 string
    # Make sure your neomodel supports JSON fields
    interests_and_goals = serializers.JSONField()

    def create(self, validated_data):
        # Use your model's method to create a new Student instance
        return Student.create(**validated_data)

    def update(self, instance, validated_data):
        # Update the Student instance
        instance.forename = validated_data.get('forename', instance.forename)
        instance.surname = validated_data.get('surname', instance.surname)
        instance.dob = validated_data.get('dob', instance.dob)
        instance.bio = validated_data.get('bio', instance.bio)
        instance.uni_name = validated_data.get('uni_name', instance.uni_name)
        instance.degree = validated_data.get('degree', instance.degree)
        instance.semester = validated_data.get('semester', instance.semester)
        instance.profile_picture = validated_data.get(
            'profile_picture', instance.profile_picture)
        instance.interests_and_goals = validated_data.get(
            'interests_and_goals', instance.interests_and_goals)
        instance.save()
        return instance


class StudentFriendSerializer(serializers.Serializer):
    # Assuming you have a relationship between students
    friend = StudentSerializer()
    # Add any other fields you need here

    def create(self, validated_data):
        # Create and return a new `Student` instance, given the validated data
        return Student.create(**validated_data)

    def update(self, instance, validated_data):
        # Update and return an existing `Student` instance, given the validated data
        instance.friend = validated_data.get('friend', instance.friend)
        instance.save()
        return instance
