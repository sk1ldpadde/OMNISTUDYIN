from data_logic.models import *

from datetime import date

from argon2 import PasswordHasher, exceptions


# TODO write tests to validate function

def compute_current_age(student: Student):
    today = date.today()

    age = today.year - student.year

    # check if birthday already happend this year
    if today.month <= student.dob.month:
        if today.month == student.dob.month and today.day < student.dob.day:
            age -= 1
    
    return age


# Check if the given password matches the stored salted hash
def check_credentials(stored_pwd, request_pwd):
    ph = PasswordHasher()
    try:
        ph.verify(stored_pwd, request_pwd)
        return True
    except exceptions.VerifyMismatchError:
        # The password does not match the hash
        return False