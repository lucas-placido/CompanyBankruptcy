import os
import subprocess
from zipfile import ZipFile

'''
Kaggle dataset url: 
    https://www.kaggle.com/datasets/utkarshx27/american-companies-bankruptcy-prediction-dataset
'''
os.environ['KAGGLE_USERNAME'] = "your_username"
os.environ['KAGGLE_KEY'] = "your_kaggle_token"

directory = os.getcwd()

zip_data_folder = directory +  "/data/zip_data/"
raw_data_folder = directory + "/data/raw_data/"

# Create data folder if not exists
os.makedirs(zip_data_folder, exist_ok=True)
os.makedirs(raw_data_folder, exist_ok=True)

os.chdir(zip_data_folder)

# Download cars dataset
kaggle_request = f"kaggle datasets download -d utkarshx27/american-companies-bankruptcy-prediction-dataset"
subprocess.run(kaggle_request, shell = True, check=True)

file_name = os.listdir(zip_data_folder)[0]
# Extract data from zipfile
with ZipFile(zip_data_folder + file_name, 'r') as f:
    f.extractall(raw_data_folder)