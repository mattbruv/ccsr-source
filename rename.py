import os
import shutil
import re

# Change this to your folder
source_folder = "dexter"

# Regex to match the pattern before and after the number
pattern = r"(.*?)_\d+_(.*)"

for filename in os.listdir(source_folder):
    # Skip directories
    if not os.path.isfile(os.path.join(source_folder, filename)):
        continue

    # Match the pattern for any number
    match = re.match(pattern, filename)
    if match:
        # Folder name is the part before the number
        folder_name = match.group(1)

        # New filename is the part after the number
        new_filename = match.group(2)

        # Folder path where the file should go
        folder_path = os.path.join(source_folder, folder_name)

        # Create the folder if it doesn't exist
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)

        # Check for filename conflicts and create unique names if necessary
        destination = os.path.join(folder_path, new_filename)
        counter = 1
        while os.path.exists(destination):  # If a file with the same name exists
            name, ext = os.path.splitext(new_filename)
            new_filename = f"{name}_{counter}{ext}"  # Append a number to make it unique
            destination = os.path.join(folder_path, new_filename)
            counter += 1

        # Move and rename the file
        shutil.move(os.path.join(source_folder, filename), destination)

        print(f"Moved {filename} -> {destination}")
