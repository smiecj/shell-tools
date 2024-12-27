
# host port
c.JupyterHub.ip = '0.0.0.0'
c.JupyterHub.port = {jupyterhub_port}

# allow origin
c.ServerApp.allow_origin = '*'
c.Spawner.args = ['--NotebookApp.allow_origin=*']

# resource
# c.Spawner.mem_limit = "1G"
# c.Spawner.cpu_limit = 2

# db
db_host = "{database_host}"
db_port = "{database_port}"
db_user = "{database_user}"
db_password = "{database_password}"
db_db = "{database_db}"

if db_host != "":
    c.JupyterHub.db_url = f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_db}"

# proxy
c.ConfigurableHTTPProxy.should_start = True

# auth
c.JupyterHub.authenticator_class = '{jupyterhub_auth_authenticator}'

## dummy password
c.DummyAuthenticator.password = '{jupyterhub_auth_dummy_password}'

## user
user_group = "{user_group}"

## auto create user
# if c.JupyterHub.authenticator_class != 'jupyterhub.auth.DummyAuthenticator':
from subprocess import check_call, call
def pre_spawn_hook(spawner):
    username = spawner.user.name
    user_home = f'/home/{username}'
    user_jupyterlab_config_home=f'{user_home}/.jupyter/lab/user-settings/'
    try:
        if user_group != "":
            call(['groupadd', user_group])
        call(['useradd', '-ms', '/bin/bash', username])
        call(['ln', '-s', '{jupyterhub_share_path}', user_home])
        
        check_call(['mkdir', '-p', f'{user_jupyterlab_config_home}'])
        call(f'cp -r {jupyterhub_user_config_home}/* {user_jupyterlab_config_home}', shell=True)
        check_call(['chown', '-R', f"{username}:{username}", user_home])
    except Exception as e:
        print(f'pre spawn err: {e}')

c.Spawner.pre_spawn_hook = pre_spawn_hook

c.Spawner.default_url = '/lab'

# culler
import sys
c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'admin': True,
        'command': [
            sys.executable,
            '-m', 'jupyterhub_idle_culler',
            '--timeout=86400'
        ],
    }
]