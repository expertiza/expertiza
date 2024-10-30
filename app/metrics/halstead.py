import os
import subprocess
import json
import pandas as pd
import glob

def _convert(directory):
        # Check if the file is a Ruby file
    if filename.endswith('.rb'):
        # Define the new filename with .py extension
        new_filename = filename.replace('.rb', '.py')
        # Get full paths
        old_file = os.path.join(directory, filename)
        new_file = os.path.join(directory, new_filename)
        # Rename the file
        os.rename(old_file, new_file)
        print(f'Renamed: {filename} -> {new_filename}')


# Function to extract specified fields from JSON
def _extract_all_json_to_csv(folder_path):
    # List to hold extracted data from all JSON files
    all_data = []

    # Iterate over all JSON files in the folder
    for json_file in glob.glob(os.path.join(folder_path, "*.json")):
        with open(json_file, 'r') as file:
            data = json.load(file)

            # Extract relevant fields: name, loc, and halstead (not within spaces)
            output_data = {
                "name": os.path.basename(json_file).replace(".py.json", ".rb"),
                "halstead": data["metrics"].get("halstead")
            }

            # Append extracted data to list
            all_data.append(output_data)

    # Convert the list of dictionaries to a DataFrame and normalize nested fields
    df = pd.json_normalize(all_data)

    return df

   


# Define the directory where your Ruby files are located
directoryModels = r'C:\Users\jacck\Documents\Github\expertiza\app\models' #File model path (replace with yours)
directoryController =  r'C:\Users\jacck\Documents\Github\expertiza\app\controllers' # File controller path (replace with yours)

# Loop through each file in the models folder
for filename in os.listdir(directoryModels):
    _convert(directoryModels)

# Loop through each file in the controller folder
for filename in os.listdir(directoryController):
    _convert(directoryController)

# Define the Rust analysis command
# need to run the open source project locally: https://github.com/mozilla/rust-code-analysis
# need Rust, Cargo, and Powershell and run the local target then .exe file
rust_tool_path = r"C:\Users\jacck\Documents\Github\rust-code-analysis\target\debug\rust-code-analysis-cli.exe" # replace with yours
output_path = r"C:\Users\jacck\Documents\Github\expertiza\app\metrics"  # replace with yours

# Run the Rust analysis tool on models folder
try:

    # This is the command line to run to analyze the code into json files
    result = subprocess.run(
        [rust_tool_path, '-m', '-O', 'json', '-o', output_path, "--pr", "-p", directoryModels],
        check=True,
        text=True,
        capture_output=True,
        shell=True  # Use shell=True on Windows for executing the command properly
    )
    print("Rust Analysis Tool Output:")
    print(result.stdout)
except subprocess.CalledProcessError as e:
    print(f"Error running Rust analysis tool: {e.stderr}")

    # Run the Rust analysis tool on controller folder
try:
    result = subprocess.run(
        [rust_tool_path, '-m', '-O', 'json', '-o', output_path, "--pr", "-p", directoryController],
        check=True,
        text=True,
        capture_output=True,
        shell=True  # Use shell=True on Windows for executing the command properly
    )
    print("Rust Analysis Tool Output:")
    print(result.stdout)
except subprocess.CalledProcessError as e:
    print(f"Error running Rust analysis tool: {e.stderr}")

print("Script completed.")

# Specify folder and output CSV paths
output_csv_path= './app/metrics/output.csv'    # Replace with your desired output CSV file path (replace with yours)

# combine dataframes
combined_df = pd.concat([_extract_all_json_to_csv(directoryModels), _extract_all_json_to_csv(directoryController)], ignore_index=True)

# Save the combined data to CSV
combined_df.to_csv(output_csv_path, index=False)
print(f"All JSON data has been combined and saved to {output_csv_path}")








