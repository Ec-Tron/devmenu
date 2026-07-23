# Dev Menu

A customizable Linux information menu written in bash.

## Features

- System Status Connection
- Battery Detection
- WiFi Status
- CPU Info
- Memory Usage
- Disk Usage
- Built in file Browser
- Command Prompt
- Multiple Banner Styles
- Plugin System
- Saved Settings

## Requirements

-Linux

-Bash 4.0+

-Standard GNU utilities (`tput`, `df`, `ps`, `date`, etc.)

## Installer and Uninstaller

-The installer makes the necessary directories and downloads the necessary files for this script, while also making an easy to remember command shortcut.

-The uninstaller deletes all files and directories related to this script.

## Installation

*Remember: before running any scripts in your terminal (including this one) take the proper precautions against malware and other attacks by understaing what you are downloading.*

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/devmenu.git
```

Enter the Project directory:
```bash
cd devmenu
```

Run the Installer:

```bash
sudo ./install.sh
```
Launch the Program:

```bash
devmenu
```

## Manual Installation

If you don't want to install system wide:

```bash
chmod +x dev-menu.sh
./devmenu.sh
```

## Plugins

Plugins go into the `Plugins/` directory.

Example plugin:

```bash
#!/usr/bin/env bash

PLUGIN_NAME="Example Plugin"

plugin_run() {
	echo "Hello from my plugin!"
	read -p "Press Enter..."
}
```

## Screenshots

*(Add Screenshots here Later.)*

## Contributing

Pull requests, bug reports, and feature suggestions are welcome.

## License

This project is licensed under the APACHE 2.0 License. See the LICENSE file for more Info.
