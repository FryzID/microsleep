#!/bin/bash


PYTHON_SCRIPT="/home/orangepi/microsleep/test.py"

USB_DEVICE_IDENTIFIER="JETE-W7"

MAX_RESTART_ATTEMPTS=20

log_message() {
    echo "$(date): $1" >> /home/orangepi/microsleep/log1.log
}

is_device_connected() {
    lsusb | grep -q "$USB_DEVICE_IDENTIFIER"
    return $?
}

main_monitor() {
    local restart_count=0

    if ! is_device_connected; then
        log_message "USB device not detected."
        return 1
    fi

    python3 "$PYTHON_SCRIPT"
    local exit_status=$?

    if [ $exit_status -ne 0 ]; then
        restart_count=$((restart_count + 1))
        
        log_message "Python script crashed with exit status $exit_status (Restart attempt $restart_count)"
        
        if [ $restart_count -ge $MAX_RESTART_ATTEMPTS ]; then
            log_message "Max restart attempts reached. Stopping."
            return 1
        fi
        sleep 5

        main_monitor
        return $?
    fi

    return 0
}



while true; do
    main_monitor
    
    sleep 30
done