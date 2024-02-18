from django.db import models
from django.contrib.auth.models import AbstractUser

# Create your models here.

# student model
class Student(AbstractUser):
    forename =    models.CharField(max_length=25)
    surname =     models.CharField(max_length=25)
    native_lang = models.CharField(max_length=25)
    zip_code =    models.IntegerField()

    # personal text
    bio =         models.CharField(max_length=150)
    
    # day of birth; current age is computed on demand
    dob =         models.DateField()

    # account specific information
    username =    models.CharField(max_length=25, unique=True)
    # use EmailField for predefined regex check
    email =       models.EmailField(max_length=64, unique=True)

    # student specific information
    uni_name =    models.CharField(max_length=50)
    degree =      models.CharField(max_length=30)
    semester =    models.IntegerField()

    def __str__(self):
        return self.username
    
    