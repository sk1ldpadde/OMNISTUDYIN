from rest_framework import serializers
from .models import Ad_Group, Ad, Student


class AdGroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ad_Group
        # expose all fields
        fields = '__all__'


class AdSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ad
        # expose all fields
        fields = '__all__'


class StudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        # expose all fields
        fields = '__all__'
