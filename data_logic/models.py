from neomodel import *


# Create your models here.


# Friend relationship model
class FriendRel(StructuredRel):
    # When was the friendship created
    since = DateTimeFormatProperty(format="%d-%m-%Y",
                                   default_now=True)
    
    # Is the friendship bidirectional
    bidrectional = BooleanProperty(default=False)
    
    def set_bidrectional(self, value):
        self.bidrectional = value
        self.save()    


# Student model
class Student(StructuredNode):
    # Student related information
    forename   = StringProperty(required=True)
    surname    = StringProperty()
    
    # Date of birth
    dob        = DateTimeFormatProperty(format="%d-%m-%Y")

    # Use email as unique identifier
    email      = EmailProperty(required=True)
    password   = StringProperty() # stored as salted argon2i secret hash

    # Personal text
    bio        = StringProperty()

    # University information
    uni_name   = StringProperty()
    degree     = StringProperty()
    semester   = IntegerProperty()
    
    # Profile picture - neomodel does not support file fields (blobs) 
    # so we store it as a base64 string
    profile_picture = StringProperty()
    
    # Additional information
    # TODO Use Google Geolocation API to get the location from the zip code
    zip_code   = StringProperty()
    
    """
    Interests and goals are stored as JSON objects
    
    Example:
    {
        "interests": ["Python", "Django", "Neo4j"],
        "goals": ["Learn more about Django", "Get better at Python"]
    }
    """
    interests_and_goals  = JSONProperty()
    
    # --------------------------
    # END OF STUDENT INFORMATION
    # --------------------------
    
    # Relationships
    # Bidirectional friendship relationship
    friends = RelationshipTo('Student', 
                             'FRIEND', 
                             model=FriendRel, 
                             cardinality=ZeroOrMore)
    
    def delete(self):
        # Assign unidirectional relationship for all friends
        for rel in self.friends.all():
            rel.set_bidrectional(False)
        # Delete the node
        super().delete()

    def __str__(self):
        return (self.student_id, self.email)