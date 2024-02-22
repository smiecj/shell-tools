#!/bin/bash
set -exo pipefail

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd ${home_path}

source /etc/profile

jupyterhub_home=${modules_home}/jupyterhub

# npm and python3 must install
nodejs_has_installed=`npm -v || true`
if [ -n "${nodejs_has_installed}" ]; then
    echo "nodejs has installed"
else
    echo "nodejs is not installed!"
    exit 1
fi

# conda
conda_has_installed=`conda -V || true`
if [ -n "${conda_has_installed}" ]; then
    echo "conda has installed"
else
    echo "conda has not installed!"
    exit 1
fi

# check if jupyter env exists, if not, create it
jupyter_env_name="py_jupyter"
jupyter_env_has_installed=`conda list installed -n ${jupyter_env_name} || true`
if [ -n "${jupyter_env_has_installed}" ]; then
    echo "jupyter env ${jupyter_env_name} has installed"
else
    echo "jupyter env ${jupyter_env_name} is not installed, will install it"
    conda create -y --name ${jupyter_env_name} python=${python3_version}
fi

source ${CONDA_HOME}/bin/activate ${jupyter_env_name}

# install jupyter

mkdir -p ${jupyterhub_home}
pushd ${jupyterhub_home}

## install npm component
npm install -g configurable-http-proxy@${configurable_http_proxy}

## install jupyter (lab)
pip3 install jupyterhub-idle-culler
pip3 install jupyterlab==${jupyterlab_version}
pip3 install jupyterhub==${jupyterhub_version}

## generate config
if [ -f jupyterhub_config.py ]; then
    mv jupyterhub_config.py jupyterhub_config.py_bak
fi
jupyterhub --generate-config

## mkdir public user config path (to add when user created)
common_user_config_folder=user_config
mkdir -p ${common_user_config_folder}

## port
sed -i 's/# c.JupyterHub.port.*/c.JupyterHub.port = ${jupyterhub_port}/g' jupyterhub_config.py

## authenticator: dummy
sed -i "s/# c.JupyterHub.authenticator_class.*/c.JupyterHub.authenticator_class = 'jupyterhub.auth.DummyAuthenticator'/g" jupyterhub_config.py

## dummy default passwd
echo "c.DummyAuthenticator.password = 'jupyter_Pwd0'" >> jupyterhub_config.py

# plugins & extensions
## culler
echo """import sys
c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'admin': True,
        'command': [
            sys.executable,
            '-m', 'jupyterhub_idle_culler',
            '--timeout=3600'
        ],
    }
]""" >> jupyterhub_config.py

## resource display
pip3 install jupyter-resource-usage

## code formatter
pip3 install jupyterlab-code-formatter
pip3 install autopep8 black

mkdir -p ${common_user_config_folder}/jupyterlab_code_formatter
echo '''{
    "preferences": {
        "default_formatter": {
            "python": [
                "autopep8",
                "black"
            ],
            "R": "formatR",
            "rust": "rustfmt",
            "c++11": "astyle"
        }
    },
    "black": {
        "line_length": 88,
        "string_normalization": true
    },
    "yapf": {
        "style_config": "google"
    },
    "isort": {
        "multi_line_output": 3,
        "include_trailing_comma": true,
        "force_grid_wrap": 0,
        "use_parentheses": true,
        "ensure_newline_before_comments": true,
        "line_length": 88
    },
    "formatR": {
        "indent": 2,
        "arrow": true,
        "wrap": true,
        "width_cutoff": 150
    },
    "formatOnSave": true,
    "cacheFormatters": false,
    "astyle": {
        "args": []
    },
    "ruff": {
        "args": [
            "--select=I"
        ]
    },
    "suppressFormatterErrors": false,
    "autopep8": {},
    "styler": {}
}''' > ${common_user_config_folder}/jupyterlab_code_formatter/settings.jupyterlab-settings

echo '''
from jupyterlab_code_formatter.formatters import BaseFormatter, handle_line_ending_and_magic, SERVER_FORMATTERS
class ExampleCustomFormatter(BaseFormatter):

    label = "Apply Example Custom Formatter"

    @property
    def importable(self) -> bool:
        return True

    @handle_line_ending_and_magic
    def format_code(self, code: str, notebook: bool, **options) -> str:
        return "42"

SERVER_FORMATTERS["example"] = ExampleCustomFormatter()
''' >> jupyterhub_config.py

## theme: dark
apputils_conf_home=${common_user_config_folder}/@jupyterlab/apputils-extension
mkdir -p ${apputils_conf_home}
echo '''{
    "theme": "JupyterLab Dark"
}
''' > ${apputils_conf_home}/themes.jupyterlab-settings

## fetch news & auto check update
echo '''{
    "fetchNews": "false",
    "checkForUpdates": false
}
''' > ${apputils_conf_home}/notification.jupyterlab-settings

## auto complete
completer_conf_home=${common_user_config_folder}/@jupyterlab/completer-extension
mkdir -p ${completer_conf_home}
echo '''{
    "autoCompletion": true
}
''' > ${completer_conf_home}/manager.jupyterlab-settings

## record time
notebook_extension_home=${common_user_config_folder}/@jupyterlab/notebook-extension
mkdir -p ${notebook_extension_home}
echo '''{
    "recordTiming": true
}
''' > ${notebook_extension_home}/tracker.jupyterlab-settings

## pre spawn: useradd and copy user config
echo """
from subprocess import check_call

def pre_spawn_hook(spawner):
    username = spawner.user.name
    try:
        check_call(['jupyteruserinit', username])
    except Exception as e:
        print(f'{e}')

c.Spawner.pre_spawn_hook = pre_spawn_hook
""" >> jupyterhub_config.py

popd

## copy scripts

cp ./scripts/* /usr/local/bin
chmod +x /usr/local/bin/jupyter*
sed -i "s#{jupyterhub_home}#${jupyterhub_home}#g" /usr/local/bin/jupyter*
sed -i "s#{jupyter_env_name}#${jupyter_env_name}#g" /usr/local/bin/jupyter*
sed -i "s#{common_user_config_folder}#${common_user_config_folder}#g" /usr/local/bin/jupyter*

popd
