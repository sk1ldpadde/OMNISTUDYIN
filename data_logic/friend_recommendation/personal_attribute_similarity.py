# This file includes all of the methods that are used to calculate the similarity between all users based on their personal attributes.
# Also, it includes the method to get embeddings, in order to safe them in the database.
# The similarity is then calculated using the cosine similarity, iterating through all user-embeddings and comparing them with each other.
import numpy as np
from views import Student
from sentence_transformers import SentenceTransformer

# this method calculates the embedding-vector of a given string or list of strings


def calculate_embedding(string):
    model = SentenceTransformer("all-MiniLM-L6-v2")
    if isinstance(string, str):
        return model.encode([string])
    elif isinstance(list, string):
        return model.encode(string)  # returns numpy array woth embeddings


def normalize_vector(vector):
    length = np.linalg.norm(vector)
    if length == 0:
        return vector
    return vector / length


# session related! TODO: ask daniel
# until now works with a mail --> Later maybe with the session token?


def get_current_user_dict(email: str):
    current_user = Student.nodes.get(email=email)
    return dict(student_id=current_user.student_id, goal_embedding=current_user.goal_embedding,
                interest_embedding=current_user.interest_embedding, similarity=-1)

# this method gets the embeddings of all users of the database and returns an array of dictionaries,
# containing the user-id, the embedding and a "similarity" field, which is used to store the similarity between two users (placeholder)


def get_user_embeddings():
    relevant_node_data = []
    # not sure if this is correct: returns all nodes as a list
    student_nodes = Student.nodes.all()
    for node in student_nodes:
        relevant_node_data.append(dict(student_id=node.student_id, goal_embedding=node.goal_embedding,
                                  interest_embedding=node.interest_embedding, similarity=-1))
    return relevant_node_data

# this method calculates the cosine similarity of an array of User-dicts and another user-dict
# cosine similarity is just calculating the dot product of two vectors and dividing it by the product of the two vectors' magnitudes
# in short: the cosine similarity is the cosine of the angle between two vectors: cos(θ) = (A * B) / (||A|| * ||B||)
# it directly manipulates the user_dict_array because the user-id and the embedding/similarities should always be interlinked!


def calculate_cosine_similarity(user_dict_array: list, user_dict: dict):
    user_dict["similarity"] = -1
    for other_dict in user_dict_array:
        dot_product = np.dot(other_dict, user_dict)
        magnitude_a = np.linalg.norm(other_dict)
        magnitude_b = np.linalg.norm(user_dict)
        cosine_similarity = dot_product / (magnitude_a * magnitude_b)
        user_dict_array[user_dict_array.index(
            other_dict)]["similarity"] = cosine_similarity


def calculate_similarity():
    user_dict = get_current_user_dict()
    other_user_dicts = get_user_embeddings()
    calculate_cosine_similarity(other_user_dicts, user_dict)
    return user_dict
