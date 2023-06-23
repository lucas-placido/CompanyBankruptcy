#!/bin/bash
sudo yum update -y
sudo python3 -m ensurepip
sudo pip3 install virtualenv

cd /home/ec2-user
sudo virtualenv --python="/usr/bin/python3.9" ec2-venv
source ec2-venv/bin/activate

# Create Python script
cat > script.py << EOL
import random
import requests
import json
import boto3
import uuid
import time
import os

region = "us-east-1"
access_key = "<your_access_key>"
secret_key = "your_secret_access_key"

client = boto3.client('kinesis', region_name =region,
                                    aws_access_key_id = access_key,
                                        aws_secret_access_key = secret_key)
partition_key = str(uuid.uuid4())

number_of_results = 50
r = requests.get(f"https://randomuser.me/api/?results={number_of_results}")
data = r.json()['results']

while True:
    # The following chooses a random user from the 500 random users pulled from the API in a single API call.
    random_user_index = int(random.uniform(0, (number_of_results - 1)))
    random_user = data[random_user_index]
    random_user = json.dumps(data[random_user_index])
    response = client.put_record(
            StreamName='tf-kinesis-stream',
            Data=random_user,
            PartitionKey=partition_key)
    time.sleep(random.uniform(0, 1))
    print(response)
EOL

cat > requirements.txt << EOL
boto3==1.15.0
requests==2.28.2
EOL

# Make the Python script executable
sudo chmod +x script.py

# Install librarys
sudo ec2-venv/bin/pip3 install boto3==1.15.0
sudo ec2-venv/bin/pip3 install requests==2.28.2

# Run the Python script
sudo ec2-venv/bin/python3.9 script.py &