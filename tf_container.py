import subprocess
import os
import sys

cwd = os.getcwd()

tf_init = f'''docker run \
-it \
--rm \
-v {cwd}/terraform:/projeto/ \
-w /projeto \
--env-file env.list \
hashicorp/terraform:light \
init
'''
subprocess.run(tf_init, shell = True, check=True)

# alias tform="docker run -it --rm -v %cd%/terraform:/projeto/ -w /projeto --env-file env.list hashicorp/terraform:light"
# tform init
# tform plan
# tform apply
# tform destroy