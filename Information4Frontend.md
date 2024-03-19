# Information for the Frontend by the Backend

Here are the endpoints that you can access (for reference see omnistudyin_backend/urls.py)



    `# Login/Register = Student
    path('register/', register_student, name='register_student'),
    path('login/', login_student, name='login_student'),
    path('get_all_students/', get_all_students, name='get_all_students'),
    path('get_session_student/', get_session_student, name='get_student'),
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
