import unittest

from datetime import date

from util import compute_current_age, check_credentials, check_profanity

from datetime import timedelta

from models import Student

from argon2 import PasswordHasher


class TestCurrentAgeCalculation(unittest.TestCase):
    def test_current_age_calculation(self):
        # Define test age
        age = 24
        # Define todays date
        today = date.today()
        today = date(today.year - age, today.month, today.day)

        # Define test cases
        # One student who already had birthday this year
        date_object_1 = today + timedelta(days=-1)
        # One student who did not have birthday this year
        date_object_2 = today + timedelta(days=1)

        test_student_1 = Student(dob=date_object_1.strftime("%d-%m-%Y"))
        test_student_2 = Student(dob=date_object_2.strftime("%d-%m-%Y"))

        # Act
        result_student_1 = compute_current_age(test_student_1)
        result_student_2 = compute_current_age(test_student_2)

        # Assert
        self.assertEqual(result_student_1, age)
        self.assertEqual(result_student_2, age - 1)


class TestCredentialsCheck(unittest.TestCase):
    def test_credentials_check(self):
        # Define test password
        test_pwd_1 = "test_pwd"
        test_pwd_2 = "1234_hello!?"

        # Define test cases for stored passwords
        ph = PasswordHasher()
        db_stored_pwd_1 = ph.hash(test_pwd_1)
        db_stored_pwd_2 = ph.hash(test_pwd_2)

        # Act
        check_student_1 = check_credentials(db_stored_pwd_1, test_pwd_1)
        check_student_2 = check_credentials(db_stored_pwd_2, test_pwd_2)

        # Assert
        self.assertTrue(check_student_1)
        self.assertTrue(check_student_2)


class TestProfanityCheck(unittest.TestCase):
    def test_profanity_check(self):
        # Define test cases
        test_string_1 = "Hello World"
        test_string_2 = "Fuck the World"

        check_string_1 = check_profanity(test_string_1)
        check_string_2 = check_profanity(test_string_2)

        self.assertFalse(check_string_1)
        self.assertTrue(check_string_2)


if __name__ == '__main__':
    unittest.main()
