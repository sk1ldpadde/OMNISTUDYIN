from neomodel import (config, StructuredNode, StringProperty, 
                      IntegerProperty, UniqueIdProperty, RelationshipTo,
                      EmailProperty, DateTimeFormatProperty)


# Create your models here.


# student model
class Student(StructuredNode):
    # student related information
    student_id = UniqueIdProperty()
    forename   = StringProperty(required=True)
    surname    = StringProperty()
    
    # date of birth
    dob        = DateTimeFormatProperty(format="%d-%m-%Y")

    email      = EmailProperty(required=True)
    password   = StringProperty() # stored as salted argon2i secret hash
    salt       = StringProperty()

    # personal text
    bio        = StringProperty()

    # university information
    uni_name   = StringProperty()
    degree     = StringProperty()
    semester   = IntegerProperty()

    def __str__(self):
        return (self.student_id, self.email)
    
    