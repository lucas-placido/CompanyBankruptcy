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

class ApiCall:
    def __init__(self) -> None:
        self.url = "https://randomuser.me/api/?results="
        self.number_of_results = 50

        self.stream = "tf-kinesis-stream"
        self.service = "kinesis"
        self.region = "us-east-1"

    def create_client(self):
        client = boto3.client(service_name = self.service, 
                              region_name = self.region)
        return client
    
    def requestData(self):        
        r = requests.get(self.url + str(self.number_of_results))
        data = r.json()['results']
        return data

    def putRecord(self):
        client = self.create_client()
        partition_key = str(uuid.uuid4())

        while True:
            random_user_index = int(random.uniform(0, (self.number_of_results - 1)))
            data = self.requestData()
            random_user = data[random_user_index]
            random_user = json.dumps(data[random_user_index])
            response = client.put_record(
                    StreamName=self.stream,
                    Data=random_user,
                    PartitionKey=partition_key)
            time.sleep(random.uniform(0, 1))
            print(response)

ApiCall().putRecord()
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

# Run the Python script in the background
ec2-venv/bin/python3.9 script.py > output.txt 2>&1 &