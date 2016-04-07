# osxscriptrunner

`osxscriptrunner.bash` is a script to launch other scripts once, every time and when they change. Intended to use with OS X and `launchd`.

## Notes

This script was created because I wanted to launch multiple ohter scripts when OS X boots or user logs in. Example `LaunchAgent` and `LaunchDaemon` plist files included. There is also [luggage](https://github.com/unixorn/luggage) Makefile for creating package.

Scripts in `run_once` directory are marked as launched via OS X `defaults` command.

Scripts in `run_changed` directory are also marked as launched via OS X `defaults` command. SHA checksum of script file is stored after every launch. `osxscriptrunner.bash` calculates SHA checksum every time it evaluates script in `run_changed` directory. If there is a mismatch between computed and stored SHA checksums script is launched.

Every script launched by `osxscriptrunner.bash` shoud have unique file name because of flat dictionary struture used by `defaults` command.

Use at your own risk.

## Usage
	
	scriptRunner: Runs scripts either once, every time or when it changes
	
	scriptrunner.bash -o /path/to/run_once -e /path/to/run_every -c /path/to/run_changed
	
	-h  
	show help
	
	-o /path/to/run_once
	Run scripts in 'run_once' directory only once.
	
	-e /path/to/run_every
	Run scripts in 'run_every' directory every time.
	    
	-c /path/to/run_changed
	Run scripts in 'run_changed' once and when they change (sha checksum).