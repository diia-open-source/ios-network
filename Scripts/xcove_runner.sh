#!/bin/bash

# Define a constants
OUTPUT_FILE="../../xcove_output"
PACKAGE_PATH="../.swiftpm/xcode/package.xcworkspace"
SCHEME="DiiaNetwork"
DERIVED_DATA_PATH="../../DerivedData"
TEST_RESULTS="${DERIVED_DATA_PATH}/Logs/Test"
DESTINATION='platform=iOS Simulator,name=iPhone 14,OS=latest' # verify that your xcodebuild version can use this simulator or set a simulator you need
KEY_PATH=""

# color constants
bright_red="\033[1;31;40m"
green="\033[42m"
brown="\033[43m"
none="\033[0m"

# ------------------- Preparating stage ---------------------------
# Ensure that xcov is installed and available in your machine
# Check the presence of xcov
if !command -v xcov &> /dev/null; then
    echo $bright_red"xcov not found. Please install it before running this script." $none
    exit 1
fi

while getopts :f: next_option; do
  case $next_option in
    f) KEY_PATH=${OPTARG};;
    b) echo "found option b";;
    ?) echo "unknown incoming option";;
  esac
done


if [[ -z $KEY_PATH ]]; then
  echo $brown"The script didnt get flag -f with ssh private key name. Will use default name id_rsa. Set name if need (e.g. -f file_name)" $none
  KEY_PATH="id_rsa"
else
  echo $green"The script got flag f. Will use custom ssh key name"$none
fi
echo KEY_PATH: $KEY_PATH

# Clean indicated directories if they exist or create if not
for directory in "$TEST_RESULTS" "$OUTPUT_FILE"; do
    rm -rf "$directory"
    mkdir -p "$directory"
done

# Start the SSH agent
eval "$(ssh-agent -s)"
# Add your SSH private key to the agent
ssh-add ~/.ssh/${KEY_PATH}

# ------------------- Performing stage ---------------------------
# Perform build to download and install all package dependencies
xcodebuild build -workspace "$PACKAGE_PATH" -scheme "$SCHEME" -derivedDataPath "$DERIVED_DATA_PATH" -resolvePackageDependencies

# Check the exit status of the build
BUILD_STATUS=$?

# Stop the SSH agent when done (optional)
ssh-agent -k

# Run tests to get a coverage report
if [ $BUILD_STATUS -eq 0 ]; then
  xcodebuild test -workspace "$PACKAGE_PATH" -scheme "$SCHEME" -destination "$DESTINATION" -derivedDataPath "$DERIVED_DATA_PATH" -quiet # remove -quiet if you need more logs
else
  echo "Build failed. Skipping tests and xcov."
  exit 1
fi

# Check the exit status of the tests
TEST_STATUS=$?

# Run xcov if tests passed
if [ $TEST_STATUS -eq 0 ]; then
    xcov -w "$PACKAGE_PATH" -o "$OUTPUT_FILE" -s "$SCHEME" --derived_data_path "$DERIVED_DATA_PATH"
else
  echo "Tests failed. Skipping xcov."
fi
