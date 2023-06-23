import subprocess
import os
import sys

cwd = os.getcwd()

tf_init = f'''docker run \
-it \
--rm \
-v {cwd}/terraform:/projeto/ \
-w /projeto \
--env-file ./terraform/terraform.tfvars \
hashicorp/terraform:light \
init
'''
subprocess.run(tf_init, shell = True, check=True)

# docker run -it --rm -v %cd%/terraform:/projeto/ -w /projeto --env-file ./terraform/terraform.tfvars hashicorp/terraform:light