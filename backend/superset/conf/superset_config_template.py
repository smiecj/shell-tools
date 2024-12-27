# superset/config.py

# WEBDRIVER_BASEURL = "http://0.0.0.0:{port}/"

# db
db_client = "{database_client}"
db_host = "{database_host}"
db_port = "{database_port}"
db_user = "{database_user}"
db_password = "{database_password}"
db_db = "{database_db}"
    
if db_host != "":
    SQLALCHEMY_DATABASE_URI=f'mysql+{db_client}://{db_user}:{db_password}@{db_host}:{db_port}/{db_db}'

SECRET_KEY = '{SUPERSET_SECRET_KEY}'