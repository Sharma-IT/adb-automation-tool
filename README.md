# ADB Automation Tool

This project provides a Bash script that automates the process of interacting with an Android device using ADB (Android Debug Bridge). It allows you to connect to multiple Android devices, retrieve device information, download data, run diagnostics, and reboot the devices.

# Features

- Connect to an Android device using ADB
- Retrieve device information (manufacturer, model, Android version)
- Download data from the Android device to the local system
- Run diagnostics commands on the Android device
- Reboot the Android device

# Prerequisites

- ADB (Android Debug Bridge) must be installed on your system. If you don't have ADB installed, please follow the instructions provided by the Android documentation to install it.

# Usage

1. Clone the repository:

```
git clone https://github.com/sharma-it/ADB-Automation-Tool.git
```

2. Change into the project directory:

```
cd ADB-automation-tool
```

3. Make the script executable:

```
chmod +x adb_automation.sh
```

4. Run the script with the desired options:

```
./adb_automation.sh -d DEVICE_ID1 -d DEVICE_ID2 -s SOURCE_DIR -t TARGET_DIR -c COMMAND
```

Replace `DEVICE_ID1` and `DEVICE_ID2` with the actual device IDs you want to interact with. You can specify multiple -d options to handle multiple devices. The -s option is used to specify the source directory for data download, and the -t option is used to specify the target directory for data transfer. The -c option allows you to execute a custom command on the devices.

Example usage:

```
./adb_automation.sh -d ABC123 -d DEF456 -s /path/to/source -t /path/to/target -c "adb shell am force-stop com.example.app"
```

5. Follow the prompts and monitor the script's output for any errors or status updates.

Please note that you need to have ADB installed on your system and the devices connected via USB or accessible over the network.

Feel free to customise the script or add additional functionality as needed.

# Logging

The script logs its execution details to a log file named 'script.log' in the same directory. You can refer to this log file for troubleshooting or reviewing the script's activity.

# Contributing

Pull requests are welcomed. For major changes, please open an issue first to discuss what you would like to change.

# Contact

Shubham Sharma - [My LinkedIn](https://www.linkedin.com/in/sharma-it/) - shubhamsharma.emails@gmail.com.

# License

This project is licensed under the GPL 3.0 License - see the [LICENSE](LICENSE) file for details.
