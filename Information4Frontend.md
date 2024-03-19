# Information for the Frontend by the Backend

Here are the endpoints that you can access (for reference see omnistudyin_backend/urls.py)

    `path('register/', register_student, name='register_student'), #POST
    path('login/', login_student, name='login_student'), #Hier bekommt man den JWT für die Session zurück #POST
    path('get_all_students/', get_all_students, name='get_all_students'), #GET
    path('get_adgroups/', get_ad_groups, name='get_adgroups'), #GET
    # Ab hier sind die SESSION paths, dh den folgenden Methoden muss der JWT Token mitgegeben werden (als Parameter "JWT")
    path('create_adgroup/', create_ad_group, name='adgroup'), #POST
    # get_ads_of_group is a POST request! --> needs to get the name of the ad group (ad_group_name) as a parameter in the request!
    path('get_ads_of_group/', get_ads_of_group, name='get_ads'), #POST --> ad_group_name
    # create_ads_in_group needs to get the name of the ad group (ad_group_name) as a parameter in the request (additionally to the standard params)!
    path('create_ads_in_group/', create_ads_in_group, name='create_ads'), #POST --> ad_gorup_name
    path('change_adgroup/', change_ad_group, name='change_adgroup'), #PUT
    path('change_ad_in_group/', change_ad_in_group, name='change_ad'), # ad_group_name mitgeben! #PUT
    path('get_session_student/', get_session_student, name='get_student'), #POST --> JWT mitsenden!!

    


Einfach die Paths im Frontend an den get,put... Methoden übergeben als String.

Beachtet bitte, dass ihr (sobald es steht) bei den Markierten Session paths immer den JWT mitgeben müsst.
Ebenso muss man bei 
