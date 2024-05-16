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
        student (obj): The student object.
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
        # Possible enhancement: Remove duplicates from result list
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
    add_ad(ad):
        Adds an ad to the trie.
    remove_ad(ad):
        Removes an ad from the trie.
    search(string):
        Returns a list of ads whose title matches the search string.
    """

    def __init__(self):
        """Initializes the AdsTrie with an empty Patricia Trie."""
        self.trie = StringTrie()

    def add_ad(self, ad):
        """
        Adds an ad to the trie.

        Parameters:
        title (str): The title of the ad.
        ad (obj): The ad object.
        """
        self.trie[ad.title.lower()] = ad

    def add_ad_group(self, ad_group):
        """
        Adds an ad group to the trie.

        Parameters:
        title (str): The name of the ad group.
        ad_group (obj): The ad group object.
        """
        self.trie[ad_group.name.lower()] = ad_group

    def remove_ad(self, ad):
        """
        Removes an ad from the trie.

        Parameters:
        title (str): The title of the ad.
        """
        del self.trie[ad.title.lower()]

    def remove_ad_group(self, ad_group):
        """
        Removes an ad group from the trie.

        Parameters:
        title (str): The name of the ad group.
        """
        del self.trie[ad_group.name.lower()]

    def search(self, string, ad_group=None):
        """
        Returns a list of ads whose title matches the search string.

        Parameters:
        string (str): The search string.
        ad_group (str): The ad group to search in.

        Returns:
        list: A list of ads or ad groups whose title matches the search string.
        """
        
        result_list = list(self.trie.values(prefix=string.lower()))
        
        print("--------- Test -----------------")
        
        for ad in result_list:
            if type(ad) is Ad:
                print(ad.title)
                print(ad.ad_group.name)
                print(ad.ad_group.description)
            else:
                print("Nix")
                
        print("--------- End Test -----------------")
        
        
        if ad_group is not None:
            ad_group_node = Ad_Group.nodes.get(name=ad_group)
            if ad_group_node is None:
                return []
            return list(ad for ad in result_list if type(ad) is Ad and ad.ad_group.name is ad_group)[:10]
        else:   
            return result_list[:10]


""" 
Define the trie structures for the student and ad models
TODO: Implement persistence for the trie structures
"""

student_ptrie = StudentPTrie()
ads_ptrie = AdsPTrie()
