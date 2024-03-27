from collections.abc import MutableMapping
from pytrie import StringTrie


class StudentPTrie:
    """
    A class used to represent a Patricia Trie for Students

    ...

    Attributes
    ----------
    trie : StringTrie
        a Patricia Trie for storing student data

    Methods
    -------
    add_student(forename, lastname, student):
        Adds a student to the trie.
    remove_student(forename, lastname):
        Removes a student from the trie.
    search(string):
        Returns a list of students whose name matches the search string.
    """

    def __init__(self):
        """Initializes the StudentTrie with an empty Patricia Trie."""
        self.trie = StringTrie()

    def add_student(self, student):
        """
        Adds a student to the trie.

        Parameters:
        student (obj): The student object.
        """
        self.trie[student.forename.lower()] = student
        self.trie[student.surname.lower()] = student
        self.trie[student.email.lower()] = student

    def remove_student(self, student):
        """
        Removes a student from the trie.

        Parameters:
        forename (str): The forename of the student.
        lastname (str): The lastname of the student.
        """
        del self.trie[student.forename.lower()]
        del self.trie[student.surname.lower()]
        del self.trie[student.email.lower()]

    def search(self, string):
        """
        Returns a list of students whose name matches the search string.

        Parameters:
        string (str): The search string.

        Returns:
        list: A list of students whose name matches the search string.
        """
        # TODO: remove duplicates from result list
        return list(self.trie.values(prefix=string.lower()))[:10]


class AdsPTrie:
    """
    A class used to represent a Patricia Trie for Ads

    ...

    Attributes
    ----------
    trie : StringTrie
        a Patricia Trie for storing ad data

    Methods
    -------
    add_ad(title, ad):
        Adds an ad to the trie.
    remove_ad(title):
        Removes an ad from the trie.
    search(string):
        Returns a list of ads whose title matches the search string.
    """

    def __init__(self):
        """Initializes the AdsTrie with an empty Patricia Trie."""
        self.trie = StringTrie()

    def add_ad(self, title, ad):
        """
        Adds an ad to the trie.

        Parameters:
        title (str): The title of the ad.
        ad (obj): The ad object.
        """
        self.trie[title.lower()] = ad

    def remove_ad(self, title):
        """
        Removes an ad from the trie.

        Parameters:
        title (str): The title of the ad.
        """
        del self.trie[title.lower()]

    def search(self, string):
        """
        Returns a list of ads whose title matches the search string.

        Parameters:
        string (str): The search string.

        Returns:
        list: A list of ads whose title matches the search string.
        """
        return list(self.trie.values(prefix=string.lower()))[:10]


""" 
Define the trie structures for the student and ad models
TODO: Implement persistence for the trie structures
"""

student_ptrie = StudentPTrie()
ads_ptrie = AdsPTrie()
