# Information for the Frontend by the Backend

Here are the endpoints that you can access (for reference see omnistudyin_backend/urls.py)



    `# Login/Register = Student
    path('register/', register_student, name='register_student'), #POST
    path('login/', login_student, name='login_student'), #POST
    path('get_all_students/', get_all_students, name='get_all_students'), #GET
    path('get_session_student/', get_session_student, name='get_student'), # GET
    #AB HIER MUSS MAN FAST IMMER EINEN JWT MITSENDEN --> Session bedingt
    path('delete_session_student/', delete_session_student, name='delete_student'),
    # Ad_group
    path('create_adgroup/', create_ad_group, name='adgroup'), #POST 
    path('get_adgroups/', get_ad_groups, name='get_adgroups'), #GET --> Man muss nicht den JWT mitsenden
    path('change_adgroup/', change_ad_group, name='change_adgroup'),# PUT
    path('delete_adgroup/', delete_ad_group, name='delete_adgroup'),# DELETE
    # Ad
    # get_ads_of_group is a POST request! --> needs to get the name of the ad group (ad_group_name) as a parameter in the request!
    path('get_ads_of_group/', get_ads_of_group, name='get_ads'), #POST --> ad_group_name muss als parameter rein!!
    # create_ads_in_group needs to get the name of the ad group (ad_group_name) as a parameter in the request (additionally to the standard params)!
    path('create_ads_in_group/', create_ads_in_group, name='create_ads'), #POST
    path('change_ad_in_group/', change_ad_in_group, name='change_ad'), #PUT
    path('delete_ad_in_group/', delete_ad_in_group, name='delete_ad') # DELETE`

    


Einfach die Paths im Frontend an den get,put... Methoden übergeben als String.

Beachtet bitte, dass ihr (sobald es steht) bei den Markierten Session paths immer den JWT mitgeben müsst(es schadet eig nicht, einfach immer den JWT mit zu übergeben).  
Ebenso muss man bei den Ads an sich (dadurch, dass ein ad nur innerhalb einer Gruppe existieren kann), bei ALLEN Operationen den ad_group_name in der JSON übergeben muss.



Hier noch ChatGPT Dokumentation:

General Requirements for All Views

    Authorization Header: For any view requiring authentication, the frontend must include an Authorization header with the JWT token.
    Content-Type: Requests with JSON payloads should set the Content-Type header to application/json.

Specific View Requirements
User Authentication and Registration

    register_student
        Method: POST
        JSON Attributes Required: email, password, forename, dob (Date of Birth in "dd-mm-yyyy" format)
        Description: Registers a new student. Email must be unique.

    login_student
        Method: POST
        JSON Attributes Required: email, password
        Description: Authenticates a student and returns a JWT token for session management.

JWT Token Management

    update_jwt
        Method: GET
        JSON Attributes Required: email
        Headers Required: Authorization (with current JWT token)
        Description: Refreshes the JWT token for the authenticated user. The email in the request body must match the sub claim in the JWT payload.

Student Information Management

    get_session_student, change_session_student, delete_session_student
        Methods: GET (for retrieval), PUT (for update), DELETE (for deletion)
        Headers Required: Authorization (with JWT token)
        JSON Attributes Required for PUT: Any student attribute(s) you wish to update (e.g., bio, semester)
        Description: These endpoints allow viewing, updating, or deleting the student profile associated with the session JWT.

Ad Groups Management

    get_ad_groups
        Method: GET
        Description: Retrieves all ad groups.

    create_ad_group
        Method: POST
        JSON Attributes Required: name, description
        Headers Required: Authorization (with JWT token)
        Description: Creates a new ad group. The name must be unique.

    change_ad_group, delete_ad_group
        Method: PUT (for update), DELETE (for deletion)
        JSON Attributes Required for PUT: old_name, and optionally new_name, description
        JSON Attributes Required for DELETE: name
        Headers Required: Authorization (with JWT token)
        Description: Updates or deletes an ad group. The user must be the admin of the ad group.

Ads Management

    get_ads_of_group
        Method: POST
        JSON Attributes Required: ad_group_name
        Description: Retrieves all ads belonging to a specified ad group.

    create_ads_in_group, change_ad_in_group, delete_ad_in_group
        Method: POST (for creation), PUT (for update), DELETE (for deletion)
        JSON Attributes Required for POST: ad_group_name, title, description, optionally image (as a base64 string)
        JSON Attributes Required for PUT: ad_group_name, old_title, and optionally new_title, description, image
        JSON Attributes Required for DELETE: ad_group_name, title
        Headers Required: Authorization (with JWT token)
        Description: Manages (creates, updates, deletes) ads within a specified ad group. The user must be the admin of the ad.

Search Functionality

    search_ads, search_ads_by_group, search_ad_groups, search_students, search_all
        Method: POST
        JSON Attributes Required: search_string, and for some endpoints, ad_group_name
        Description: Provides various search functionalities across ads, ad groups, and students. The search_all endpoint combines the results from ads, ad groups, and students into a single response.


        
