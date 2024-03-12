from models import *
from datetime import date

# TODO write tests to validate function

def compute_current_age(student: Student):
    today = date.today()

    age = today.year - student.year

    # check if birthday already happend this year
    if today.month <= student.dob.month:
        if today.month == student.dob.month and today.day < student.dob.day:
            age -= 1
    
    return age