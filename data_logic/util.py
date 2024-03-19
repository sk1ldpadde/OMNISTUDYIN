from models import *

from datetime import date
from datetime import datetime

from argon2 import PasswordHasher, exceptions

from better_profanity import profanity


# TODO write tests to validate function

def compute_current_age(student: Student):
    today = date.today()
    student_dob = datetime.strptime(student.dob, "%d-%m-%Y")

    age = today.year - student_dob.year

    # check if birthday already happend this year
    if (today.month, today.day) < (student_dob.month, student_dob.day):
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


def check_profanity(string: str):
    return profanity.contains_profanity(string)
