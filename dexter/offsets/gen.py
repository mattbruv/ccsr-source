import os
import glob
import csv
import json

# Global list to hold the parsed data
global_list = []

# Specify the directory where the CSV files are located
directory = '.'  # Replace with your directory path

# Get a list of all *.csv files in the directory
csv_files = glob.glob(os.path.join(directory, '*.csv'))

# Iterate through each CSV file
for file in csv_files:
    #print(f"Processing file: {file}")
    
    with open(file, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        
        # Iterate through each row in the CSV file
        for row in reader:
            name = row['Name']
            registration_point = row['Registration Point']
            
            # Parse the registration point (xnumber, ynumber) into x and y
            registration_point = registration_point.strip('()')  # Remove parentheses
            x, y = map(int, registration_point.split(','))  # Split and convert to integers
            
            # Add the data to the global list
            global_list.append({
                'name': name,
                'offset': {
                    'x': x,
                    'y': y
                }
            })

# Print the global list as JSON
print(json.dumps(global_list, indent=4))
