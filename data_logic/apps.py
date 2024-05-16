"""
This module contains the configuration for the 'data_logic' app.

The 'DataLogicConfig' class is an AppConfig subclass that defines the configuration
for the 'data_logic' app. It sets the default auto field to 'django.db.models.BigAutoField'
and specifies the name of the app as 'data_logic'.
"""

from django.apps import AppConfig


class DataLogicConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'data_logic'
