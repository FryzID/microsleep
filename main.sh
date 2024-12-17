#!/bin/bash

# Path to your Python script
PYTHON_SCRIPT="./test.py"

# USB device identifier (replace with your specific device string)
USB_DEVICE_IDENTIFIER="JETE-W7"

# Function to check if the USB device is connected
is_device_connected() {
    lsusb | grep -q "$USB_DEVICE_IDENTIFIER"
    return $?
}

# Main monitoring loop
while true; do
    # Check if the USB device is connected
    if is_device_connected; then
        echo "Webcam Connected"
        # Run the Python script and keep it running
        while true; do
            python3 "$PYTHON_SCRIPT"
            
            # Check the exit status
            EXIT_STATUS=$?
            
            # If script exits with non-zero status (crashed), log and retry
            if [ $EXIT_STATUS -ne 0 ]; then
                echo "$(date): Python script crashed with exit status $EXIT_STATUS. Restarting in 5 seconds..." >> /path/to/logfile.log
                sleep 5
                continue
            fi
            
            # If script exits normally, break inner loop to recheck USB device
            break
        done
    else
        # If device not connected, wait and check again
        echo "$(date): USB device not detected. Waiting..." >> /path/to/logfile.log
        sleep 30
    fi
    
    # Avoid tight looping
    sleep 10
done