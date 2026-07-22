#!/usr/bin/env bash

clear


colors="on"
CONFIG_FILE="$HOME/.devmenu.conf"
PLUGIN_DIR="$(dirname "$0")/plugins" 

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

color_echo() {
	printf "%b\n" "$1"
}
check_dependencies() {

	required_commands=(
		"tput"
		"date"
		"cat"
		"df"
		"ps"
	)

	missing=()

	for cmd in "${required_commands[@]}"; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			missing+=("$cmd")
		fi
	done

	if [ "${#missing[@]}" -gt 0 ]; then
		echo "Missing required commands:"
		for cmd in "${missing[@]}"; do
			echo "- $cmd"
		done
		exit 1
	fi
}
check_dependencies
banner="dev"
menu_items=( 
	"Current Date & Time"
	"System Uptime"
	"Current User"
	"Operating System"
	"CPU Info"
	"Memory Usage"
	"Disk Usage"
	"Bash Version"
	"Environment Variables"
	"Running Processes"
	"Command Prompt"
	"Settings Menu"
	"File Browser" 
)
MENU_OPTIONS=${#menu_items[@]}

show_banner() {

	if [ "$banner" = "dev" ]; then
		color_echo "${GREEN}+---------------------------+${RESET}"
		printf "%b\n" "${GREEN}|       DEV MENU V1.0       |${RESET}"
		printf "%b\n" "${GREEN}|         LINUX INFO        |${RESET}"
		color_echo "${GREEN}+---------------------------+${RESET}"


	elif [ "$banner" = "linux" ]; then
		color_echo "${RED}"
		cat <<'EOF'
Linux   .--.
System |o o|
Menu   | v |
      //  \ \
     (|    | )
    /'\_  _/`\
    \___)(___/
EOF
		color_echo "${RESET}"
		echo
		echo
		echo

	elif [ "$banner" = "simple" ]; then
		echo "================="
		echo " SYSTEM DEV MENU "
		echo "================="
	elif [ "$banner" = "lightning" ]; then
		color_echo "${YELLOW}"
		cat <<'EOF'
           ____
          /   /
         /   /
  Linux /   /___Menu 
       /___    /
          /   /
         /   /
        /   /
       /___/
EOF
		color_echo "${RESET}"

	elif [ "$banner" = "dragon" ]; then
		color_echo "${RED}"
		cat <<'EOF'
Linux  /\__
System(   @\___
Menu  /        O
     /  (_____/
    /____/   U
EOF
		color_echo "${RESET}"
	fi
}

load_settings() {
	if [ -f "$CONFIG_FILE" ]; then
		source "$CONFIG_FILE"
	fi
}

load_settings

save_settings() {
	echo "colors=\"$colors\"" > "$CONFIG_FILE"
	echo "banner=\"$banner\"" >> "$CONFIG_FILE"
}

plugin_names=()
plugin_paths=()

if [ -d "$PLUGIN_DIR" ]; then

	for file in "$PLUGIN_DIR"/*.sh; do 
		[ -f "$file" ] || continue

		PLUGIN_NAME=""

		PLUGIN_NAME=$(grep '^PLUGIN_NAME=' "$file" | cut -d '=' -f2 | tr -d '"')

		if [ -n "$PLUGIN_NAME" ]; then
			plugin_names+=("$PLUGIN_NAME")
			plugin_paths+=("$file")
		fi
	done
fi

show_dashboard() {

	cols=$(tput cols 2>/dev/null)

	if [ -z "$cols" ]; then
		cols=80
	fi

	dashboard_col=$((cols - 32))

	if [ "$dashboard_col" -lt 1 ]; then
		dashboard_col=1
	fi

	tput cup 1 "$dashboard_col" 
	color_echo "${BLUE}================================${RESET}"

	tput cup 2 "$dashboard_col"
	color_echo "${BLUE}         SYSTEM STATUS          ${RESET}"

	tput cup 3 "$dashboard_col"
	color_echo "${BLUE}================================${RESET}"
	
	battery="N/A"

	for bat in /sys/class/power_supply/BAT*/capacity; do
		if [ -f "$bat" ]; then
			battery=$(cat "$bat")
			break
		fi
	done

	tput cup 4 "$dashboard_col"

	if [ "$battery" != "N/A" ]; then
		printf "%b\n" "${GREEN}Battery:${RESET} ${battery}%"
	else
		printf "%b\n" "${YELLOW}Battery:${RESET} N/A"
	fi

	tput cup 4 "$dashboard_col"

	wifi_status="down"

	for iface in /sys/class/net/*; do
		if [ -d "$iface/wireless" ]; then
			wifi_name=$(basename "$iface")
			wifi_status=$(cat "/sys/class/net/$wifi_name/operstate" 2>/dev/null)
			break
		fi
	done

	tput cup 5 "$dashboard_col"

	if [ "$wifi_status" = "up" ]; then
		printf "%b\n" "${GREEN}WiFi:${RESET} Connected"
	else
		printf "%b\n" "${YELLOW}WiFi:${RESET} Disconnected"
	fi

	tput cup 6 "$dashboard_col"
	printf "%b\n" "${GREEN}Time:${RESET} $(date '+%I:%M %p')"

	tput cup 0 0 
}
tput cup 0 0
show_menu() {
	echo
	echo
	echo
	echo
	echo
	echo
	echo
	echo
	echo
	echo
	for i in "${!menu_items[@]}"; do
		number=$((i + 1))
		printf "%b\n" "${GREEN}${number}) ${menu_items[$i]}${RESET}"
	done

	color_echo "${GREEN}0) Exit${RESET}"
	echo
	color_echo "${BLUE}====PLUGINS====${RESET}"

	plugin_start=$((${#menu_items[@]}  + 1)) 

	for i in "${!plugin_names[@]}"; do
		echo "$((plugin_start + i))) ${plugin_names[$i]}"
	done
	echo
}

file_browser() {
	current_dir="$HOME"

	while true
	do
		clear

		echo "====File Browser===="
		echo
		echo "Current Directory:"
		echo "$current_dir"
		echo

		if [ "$input" = "ls" ]; then
			ls -lah "$current_dir"
			echo
			read -p "Press Enter..."
		fi

		echo
		echo "Commands:"
		echo "cd <folder>"
		echo "open <file>"
		echo "up"
		echo "back"
		echo

		read -p "File Browser> " input

		if [ "$input" = "back" ]; then
			return
		fi

		if [ "$input" = "up" ]; then
			current_dir=$(dirname "$current_dir")
		fi

	     	if [[ "$input" = cd\ * ]]; then

	     		folder="${input#cd }"

	     		if [ -d "$current_dir/$folder" ]; then
	     			current_dir="$current_dir/$folder"
			else
				echo "Folder not found."
				sleep 2
			fi
		fi

		if [[ "$input" == open\ * ]]; then
			file="${input#open }"

			clear

			if [ -f "$current_dir/$file" ]; then
				cat "$current_dir/$file"
			else
				echo "File not found."
			fi

			echo
			read -p "Press Enter..."
		fi
	done
}

settings_menu() {
	while true
	do
		clear

		echo "===== SETTINGS ====="
		echo
		echo "1) Toggle Colors"
		echo "2) Change Banner"
		echo "3) About"
		echo "0) Return"
		echo

		read -p "Choice:" settings

		case "$settings" in
			1)
				if [ "$colors" = "on" ]; then
					colors="off"

					GREEN=""
					BLUE=""
					YELLOW=""
					RED=""
					RESET=""

					echo "Colors Disabled."
					save_settings
				else
					colors="on"

					GREEN="\033[0;32m"
					BLUE="\033[0;34m"
					YELLOW="\033[1;33m"
					RED="\033[0;31m"
					RESET="\033[0m"

					echo "Colors Enabled."
					save_settings
				fi
				;;
			2)
				clear
				echo "==== Banner Selection===="
				echo
				echo "1) DEV MENU"
				echo "2) LINUX PENGUIN"
				echo "3) Simple"
				echo "4) Lightning"
				echo "5) Dragon" 
				echo "0) Return"
				echo

				read -p "Choose Banner: " banner_choice

				case "$banner_choice" in
					1)
						banner="dev"
						echo "DEV MENU selected."
						save_settings
						;;
					2)
						banner="linux"
						echo "Linux Penguin selected."
						save_settings
						;;
					3)
						banner="simple"
						echo "Simple Banner selected."
						save_settings
						;;
					4)
						banner="lightning"
						echo "Lightning banner selected."
						save_settings
						;;
					5)
						banner="dragon"
						echo "Dragon banner selected."
						save_settings
						;;
					0)
						;;
					*)
						echo "Invalid Choice."
						;;
				esac
				;;


			3)
				echo "+--------------------------------------------------+"
				echo "|                 Developer Menu                   |"
				echo "|                 ==============                   |"
				echo "| Version: 1.0                   Written in: Bash  |"
				echo "|              Author:EC_TRON                      |"
				echo "+--------------------------------------------------+"
				;;
			0)
				return
				;;
			*)
				echo "Invalid Choice."
				;;
		esac

		echo
		read -p "Press Enter..."
	done
}

while true
do
clear

show_banner

	show_dashboard
	tput cup 0 0
	show_menu

	read -r -p "Enter The Number of Your Choice:  " choice
	clear
	echo

	if [[ "$choice" =~ ^[0-9]+$ ]]; then
	
		if (( choice >= plugin_start )); then

			index=$((choice - plugin_start))

			if (( index >= 0 && index < ${#plugin_paths[@]} )); then

				source "${plugin_paths[$index]}"

				if command -v plugin_run >/dev/null 2>&1; then
					plugin_run
				else
					echo "Plugin error: plugin_run not found."
				fi

				unset -f plugin_run
				continue
			fi
		fi
	fi

	case "$choice" in
	1)
		echo "====Current Date===="
		date "+%A, %B  %d, %Y"

		echo
		echo "====Current Time===="
		date "+%I:%M:%S %p"
		;;
	2)
		echo "====System Uptime===="
		uptime
		;;
	3)
		echo "====Current User===="
		whoami
		;;
	4)
		echo "====Operating System===="

		if [ -f /etc/os-release ]; then

			distro=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d '"' -f2)

			if [ -n "$distro" ]; then
				echo "Distribution: $distro"
			else
				echo "Distribution: Unknown"
			fi

			echo "Kernel: $(uname -r)"
			echo "Architecture: $(uname -m)"
		else

			echo "Operating System: Unknown"
			echo "Kernel: (uname -r)"
			echo "Architecture: $(uname -m)"
		fi
		;;
	5)
		echo "====CPU Info===="
		if command -v lscpu >/dev/null 2>&1; then
			lscpu | grep -E "Model name|CPU\(s\)|Core|Thread|MHz"
		else
			cat /proc/cpuinfo
		fi
		;;
	6)
		echo "====Memory Usage===="
		free -h
		;;
	7)
		echo "====Disk Usage===="
		df -h
		;;
	8)
		echo "====Bash Version===="
		bash --version
		;;
	9)
		echo "====Environment Variables===="
		env
		;;
	10)
		echo "====Running Processes===="
		ps
		;;
 	11)
 		clear
 		echo "====Command Prompt===="
 		echo
 		color_echo "${RED}WARNING: THIS IS NOT A SANDBOX ENVIRONMENT AND COMMANDS ENTERED HERE RUN ON THE MAIN SYSTEM"
 		color_echo "${RESET}Type a Linux command to run."
 		echo "Type 'back' to return."

 		while true
 		do
 			read -p "Command> " cmd

 			if [ "$cmd" = "back" ]; then
 				break
			fi

			echo

			if [ -n "$cmd" ]; then
				bash -c "$cmd"
			fi

			echo
		done
		;;
	12)
		settings_menu
		;;
	13)
		file_browser
		;;
	0)
		echo "Goodbye!"
		exit 0
		;;
	*)
		echo "Invalid Choice."
		;;
	esac
 	echo
 	read -p "Press Enter to return to the menu..."
 	clear
done
