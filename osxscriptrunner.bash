#!/bin/bash

# Author: MichalM.Mac

readonly IDENTIFIER='cz.osxadmin.osxscriptrunner'

function usage() {
cat <<EOF

  scriptRunner: Runs scripts either once or every time

  scriptrunner.bash -o /path/to/run_once -e /path/to/run_every -c /path/to/run_changed

  -h  
    show help

  -o /path/to/run_once
    Run scripts in 'run_once' directory only once

  -e /path/to/run_every
    Run scripts in 'run_every' directory every time
    
  -c /path/to/run_changed
    Run scripts in 'run_changed' once and when they change (checksum)
    
EOF
}

function log_to_syslog() {
  local message_to_log="$1"
  local log_level="$2"
  syslog -s -k Facility "$IDENTIFIER" Level "$log_level" Sender "$IDENTIFIER" Message "$message_to_log"
  echo "$message_to_log"
}

function parse_opts() {
  while getopts "ho:e:c:" opt; do
    case $opt in
      h)
        usage
        exit 0
        ;;
      o)
        readonly RUNONCE_DIR="${OPTARG%/}"
        ;;
      e)
        readonly RUNEVERY_DIR="${OPTARG%/}"
        ;;
      c)
        readonly RUNCHANGED_DIR="${OPTARG%/}"
        ;;
      \?)
        log_to_syslog "Invalid option ${OPTARG}" "Error"
        exit 1
        ;;
      :)
        log_to_syslog "Option ${OPTARG} requires an argument." "Error"
        exit 1
        ;;
    esac
  done
  
  shift "$((OPTIND-1))"
}

function run_script() {
  local iscript="$1"
  
  if [ -f "$iscript" -a -x "$iscript" ]; then
    "$iscript"
    log_to_syslog "Script completed: $iscript" "Info"
  else
    log_to_syslog "Unable to run script: ${iscript}" "Error"
  fi 
}

function folder_is_empty() {
  local folder="$1"
  if test -n "$(shopt -s nullglob; echo ${folder}/*)"
  then
    return 1
  else
    return 0
  fi
}

function run_once() {
    
  folder_is_empty "$RUNONCE_DIR" && return

  for iscript in "$RUNONCE_DIR"/* ; do
    local script_name=$(basename "$iscript")
    local script_didrun=$(defaults read "$IDENTIFIER" "$script_name" 2> /dev/null)
    if [ "$script_didrun" != "true" ]; then
      run_script "$iscript" && 
          defaults write "$IDENTIFIER" "$script_name" "true"
    fi
  done
}

function run_every() {
    
  folder_is_empty "$RUNEVERY_DIR" && return
  
  for iscript in "$RUNEVERY_DIR"/* ; do
    run_script "$iscript"
  done
}

function run_changed() {
  
  folder_is_empty "$RUNCHANGED_DIR" && return

  for iscript in "$RUNCHANGED_DIR"/* ; do
    local script_name=$(basename "$iscript")
    local script_previous_sha=$(defaults read "$IDENTIFIER" "$script_name" 2> /dev/null)
    local script_current_sha=$(shasum "$iscript" | cut -d' ' -f1)
    
    if [ "$script_previous_sha" != "$script_current_sha" ]; then
      run_script "$iscript" && 
          defaults write "$IDENTIFIER" "$script_name" "$script_current_sha"
    fi
  done
}

function main() {
  parse_opts "$@"
  
  if [ -d "$RUNONCE_DIR" ]; then
    run_once
  else
    log_to_syslog "invalid directory: ${RUNONCE_DIR}" "Error"
  fi
  
  if [ -d "$RUNEVERY_DIR" ]; then
    run_every
  else
    log_to_syslog "invalid directory: ${RUNEVERY_DIR}" "Error"
  fi 
  
  if [ -d "$RUNCHANGED_DIR" ]; then
    run_changed
  else
    log_to_syslog "invalid directory: ${RUNCHANGED_DIR}" "Error"
  fi
  
}
main "$@"