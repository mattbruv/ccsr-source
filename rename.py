import csv
import os
import glob
import shutil

# Settings
data_dir = '.'  # directory where the CSVs and images are
output_dir = 'output'  # where the new folders/files will go
os.makedirs(output_dir, exist_ok=True)

# Step 1: Read Casts.csv to get mapping of number -> folder name
casts_path = os.path.join(data_dir, 'Casts.csv')
number_to_folder = {}

with open(casts_path, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        num = row['Number'].strip()
        folder_name = row['Name'].strip()
        if num and folder_name:
            # Create subfolder named ONLY by the folder_name
            folder_path = os.path.join(output_dir, folder_name)
            os.makedirs(folder_path, exist_ok=True)
            number_to_folder[num] = folder_path

# Step 2: Process each *_Members.csv
for members_csv in glob.glob(os.path.join(data_dir, '*_Members.csv')):
    base_number = os.path.basename(members_csv).split('_')[0]

    with open(members_csv, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            number = row['Number'].strip()
            name = row['Name'].strip()
            
            if not number or not name:
                continue

            # Match files like 13_2.bmp, 13_2.png, etc.
            pattern = os.path.join(data_dir, f"{base_number}_{number}.*")
            matches = glob.glob(pattern)

            for match in matches:
                ext = os.path.splitext(match)[1]
                new_filename = f"{name}{ext}"
                dest_folder = number_to_folder.get(base_number)
                
                if dest_folder:
                    shutil.copy(match, os.path.join(dest_folder, new_filename))
                    print(f"Renamed {os.path.basename(match)} -> {new_filename} in {dest_folder}")
                else:
                    print(f"No destination folder for {base_number}")

print("Done!")
