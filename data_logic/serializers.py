from rest_framework import serializers
from .models import Ad_Group, Ad, Student

# custom Serializers for the models


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
    dob = serializers.DateField()  # Adjust the field type if needed
    email = serializers.EmailField()
    # Ensure this is write-only for security
    password = serializers.CharField(write_only=True)
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
        instance.email = validated_data.get('email', instance.email)
        instance.password = validated_data.get('password', instance.password)
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
