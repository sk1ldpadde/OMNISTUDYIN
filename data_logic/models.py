"""
This module contains the data models for the OMNISTUDYIN application.

The models include:
- FriendRel: Represents the friendship relationship between students.
- Message: Represents a message sent between students.
- Student: Represents a student in the application.
- Ad_Group: Represents a group of ads.
- Ad: Represents an advertisement.

Each model has its own properties and relationships defined.

Note: The module uses the neomodel library for object-graph mapping to Neo4j.
"""

from neomodel import *


# Create your models here.


# Friend relationship model
class FriendRel(StructuredRel):
    # When was the friendship created
    since = DateTimeFormatProperty(format="%d-%m-%Y",
                                   default_now=True)

    # Is the friendship bidirectional
    bidirectional = BooleanProperty(default=False)

    def set_bidrectional(self, value):
        self.bidrectional = value
        self.save()


# Message model
class Message(StructuredNode):
    fromStudent = StringProperty(required=True)
    content = StringProperty(required=True)
    timestamp = DateTimeFormatProperty(format="%Y-%m-%d %H:%M:%S")
    isRead = BooleanProperty(default=False)
    own_msg = BooleanProperty(default=False)

    def to_dict(self):
        return {
            'fromStudent': self.fromStudent,
            'content': self.content,
            'timestamp': self.timestamp.strftime("%Y-%m-%d %H:%M:%S") if self.timestamp else None,
            'isRead': self.isRead,
            'own_msg': self.own_msg,
        }


# Student model
class Student(StructuredNode):
    # Student related information
    forename = StringProperty(required=True)
    surname = StringProperty()

    # Date of birth
    dob = DateTimeFormatProperty(format="%d-%m-%Y")

    # Use email as unique identifier
    email = EmailProperty(required=True)
    password = StringProperty()  # stored as salted argon2i secret hash

    # Personal text
    bio = StringProperty()

    # University information
    uni_name = StringProperty()
    degree = StringProperty()
    semester = IntegerProperty()

    # Profile picture - neomodel does not support file fields (blobs)
    # so we store it as a base64 string
    profile_picture = StringProperty()

    # Additional information
    zip_code = StringProperty()

    """
    Interests and goals are stored as JSON objects
    
    Example:
    {
        "interests": ["Python", "Django", "Neo4j"],
        "goals": ["Learn more about Django", "Get better at Python"]
    }
    """
    interests_and_goals = JSONProperty()

    # --------------------------
    # END OF STUDENT INFORMATION
    # --------------------------

    # Relationships
    # Bidirectional friendship relationship
    friends = RelationshipTo('Student',
                             'FRIEND',
                             model=FriendRel,
                             cardinality=ZeroOrMore)

    # Relationship for incoming chat messages
    incoming_chat_messages = RelationshipFrom(
        'Message', 'TO', cardinality=ZeroOrMore)

    creator_of_ad_group = RelationshipTo(
        'Ad_Group', 'ADMIN', cardinality=ZeroOrMore)

    creator_of_ad = RelationshipTo('Ad', 'ADMIN', cardinality=ZeroOrMore)

    def delete(self):
        # Assign unidirectional relationship for all friends
        for rel in self.friends.all():
            rel.set_bidrectional(False)
        # Delete the node
        super().delete()

    def __str__(self):
        return f"{self.forename} {self.surname} ({self.email})"


# Ad_group model: Ad group is a collection of ads kind of like a "subreddit"

class Ad_Group(StructuredNode):
    # Ad group information
    name = StringProperty()
    description = StringProperty()

    # Relationships
    # Ad group has many ads
    ads = RelationshipFrom('Ad', 'AD_IN', cardinality=ZeroOrMore)

    # Ad group is created by a student --> Admin of the ad group
    # Cardinality is ZeroOrMore because a student can create multiple ad groups,
    # but we also want to have the possibility to have "standard groups" which are created by the system
    admin = RelationshipFrom('Student', 'ADMIN', cardinality=ZeroOrMore)

    def __str__(self):
        return self.name

    def delete(self):
        # Delete all ads in the group
        for ad in self.ads.all():
            ad.delete()
        # Delete the ad group
        super().delete()


class Ad(StructuredNode):
    # Ad information
    title = StringProperty()
    description = StringProperty()
    # Image is stored as a base64 string
    image = StringProperty()

    # Relationships
    # Ad belongs to an ad group
    ad_group = RelationshipTo('Ad_Group', 'AD_IN', cardinality=One)

    # Ad is created by a student --> Admin of the ad
    # Cardinality is ZeroOrMore because of the possible implementation of "standard ads"
    admin = RelationshipFrom('Student', 'ADMIN', cardinality=ZeroOrMore)

    def __str__(self):
        return self.title

    def delete(self):
        # Delete the ad
        super().delete()
