#!/bin/bash

# Check if the script is sourced
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  echo "This script must be executed directly, not sourced!"
else
  # Get the directory where script.sh resides
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Check if config.sh exists in the same directory
  if [ ! -f "${SCRIPT_DIR}/aws_config.sh" ]; then
    echo "Error: aws_config.sh is not found in the script directory."
    echo "Please ensure that aws_config.sh exists in the same directory as aws_tool.sh."
    exit 1
  fi

  # Declare global variables shared with commands
  user=""
  project=""
  environment=""
  default_command=""
  browser=""

  # Modified from: https://stackoverflow.com/questions/42789273/bash-choose-default-from-case-when-enter-is-pressed-in-a-select-prompt
  # Shared with commands
  selectWithDefault() {
    local item i=0 numItems=$# defaultIndex=0

    # Print numbered menu items, based on the arguments passed.
    for item; do # Short for: for item in "$@"; do
      [[ "$item" == !* ]] && defaultIndex=$(($i + 1)) && item="${item:1} [default]"
      printf '%s\n' "$((++i))) $item"
    done >&2 # Print to stderr, as `select` does.

    # Prompt the user for the index of the desired item.
    while :; do
      printf %s "${PS3-#? }" >&2 # Print the prompt string to stderr, as `select` does.
      read -r index
      # Make sure that the input is either empty or that a valid index was entered.
      [[ -z $index ]] && index=$defaultIndex && break  # empty input == default choice  
      (( index >= 1 && index <= numItems )) 2>/dev/null || { echo "Invalid selection. Please try again." >&2; continue; }
      break
    done

    [[ -n $index ]] && result="${@:$index:1}"; echo "${result#"!"}"
    # [[ -n $index ]] && printf %s '${@:index:1}'
    # Output the selected *index* (1-based).
    # printf $index
  }

  # Load the configuration file
  source "${SCRIPT_DIR}/aws_config.sh"

  # Load the commands
  source "${SCRIPT_DIR}/aws_commands.sh"

  # Get (user, project, environment) from AWS_PROFILE or from the script user
  if [[ ! -z "${AWS_PROFILE}" ]]; then
    echo Found AWS_PROFILE=${AWS_PROFILE}
    IFS="_" read -r user project environment <<< "$AWS_PROFILE"
    echo User: ${user} Project: ${project} Environment: ${environment}
  else
    # Select the user
    echo Select a user:
    user=$(selectWithDefault "${users[@]}")

    # Select the project
    echo Select a project:
    project=$(selectWithDefault "${projects[@]}")

    # Select the environment
    echo Select an environment:
    environment=$(selectWithDefault "${environments[@]}")
  fi

  # List the commands declared in the configuration file
  # only available since bash 4.0
  #readarray -t commands < <(declare -F | awk '/ command/ {print $NF}')
  while IFS= read -r line; do
    commands+=("$line")
  done < <(declare -F | awk '/ command_/ {print $NF}')

  # Mark the default command with an exclamation mark if any
  if [[ -n "$default_command" ]]; then
    # Loop through the array
    for i in "${!commands[@]}"; do
      # If the current array value is equal to myvar, prepend an exclamation mark
      if [[ "${commands[$i]}" == "$default_command" ]]; then
          commands[$i]="!${commands[$i]}"
      fi
    done
  fi

  # Select the command
  echo Select a command:
  command=$(selectWithDefault "${commands[@]}")

  # Execute the command
  eval "${command} \"\$@\""
fi
