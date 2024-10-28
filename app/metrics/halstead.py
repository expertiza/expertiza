import os
import subprocess


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

# Define the directory where your Ruby files are located
directoryModels = r'C:\Users\jacck\Documents\Github\expertiza\app\models' #File model path
directoryController =  r'C:\Users\jacck\Documents\Github\expertiza\app\controllers' # File controller path

# Loop through each file in the models folder
for filename in os.listdir(directoryModels):
    _convert(directoryModels)

# Loop through each file in the controller folder
for filename in os.listdir(directoryController):
    _convert(directoryController)

# Define the Rust analysis command
rust_tool_path = r"C:\Users\jacck\Documents\Github\rust-code-analysis\target\debug\rust-code-analysis-cli.exe"
# analysis_target_path = r"C:\Users\jacck\Documents\Github\expertiza\app"
output_path = r"C:\Users\jacck\Documents\Github\expertiza\app\metrics"

# Run the Rust analysis tool on models folder
try:
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