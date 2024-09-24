#!/bin/bash

# Define the URL to fetch the latest version number
version_url="https://upgrade.mikrotik.com/routeros/NEWESTa7.stable"

# Fetch the content from the version URL using curl
version_content=$(curl -s "$version_url")

# Extract the version number using awk
version=$(echo "$version_content" | awk '{print $1}')

# Check if the version number was extracted
if [ -z "$version" ]; then
    echo "Error: Unable to extract version number."
    exit 1
else
    echo "Latest MikroTik RouterOS version: $version"
fi

# Define the base download URL
base_download_url="https://download.mikrotik.com/routeros"

# Define the architectures to download Maim Package
architectures=("" "-arm64" "-arm" "-mipsbe" "-mmips" "-ppc" "-smips")

# Loop through each architecture
for arch in "${architectures[@]}"; do
    # Construct the full download URL for each architecture
    download_url="$base_download_url/$version/routeros-$version$arch.npk"
    output_file="routeros$arch-$version.npk"
    
    # Check if the file already exists
    if [ -f "$output_file" ]; then
        # Get the size of the existing file
        existing_size=$(stat -c%s "$output_file")
        # Fetch the expected file size from the server
        expected_size=$(curl -sI "$download_url" | grep -i Content-Length | awk '{print $2}' | tr -d '\r')

        # Check if the file sizes match
        if [ "$existing_size" -eq "$expected_size" ]; then
            echo "File $output_file already exists and is complete. Skipping download."
            continue
        else
            echo "File $output_file is incomplete. Redownloading..."
            rm "$output_file"
        fi
    fi

    # Download the file using wget
    wget -O "$output_file" "$download_url"

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Downloaded $output_file successfully."
    else
        echo "Error: Failed to download $output_file."
    fi
done

# Define the architectures to download Extra Package
architectures=("x86" "arm64" "arm" "mipsbe" "mmips" "ppc" "smips")

# Loop through each architecture
for arch in "${architectures[@]}"; do
    # Construct the full download URL for each architecture
    download_url="$base_download_url/$version/all_packages-$arch-$version.zip"
    output_file="all_packages-$arch-$version.zip"
    
    # Check if the file already exists
    if [ -f "$output_file" ]; then
        # Get the size of the existing file
        existing_size=$(stat -c%s "$output_file")
        # Fetch the expected file size from the server
        expected_size=$(curl -sI "$download_url" | grep -i Content-Length | awk '{print $2}' | tr -d '\r')

        # Check if the file sizes match
        if [ "$existing_size" -eq "$expected_size" ]; then
            echo "File $output_file already exists and is complete. Skipping download."
            continue
        else
            echo "File $output_file is incomplete. Redownloading..."
            rm "$output_file"
        fi
    fi

    # Download the file using wget
    wget -O "$output_file" "$download_url"

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Downloaded $output_file successfully."
    else
        echo "Error: Failed to download $output_file."
    fi
done
