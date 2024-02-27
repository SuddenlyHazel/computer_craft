

## startup.lua

Scripts can be requested to run on a server by doing the following..

1. Add a new deployment entry in `boot.json` with the name of the server
and the requested scripts to be started by `startup.lua`
2. Add a program entry in `boot.json`. Make sure any requirements are added to `common` in `boot.json`
3. Give the server a name by running the following in the craftOs shell 
```
set "hazel.computer_craft.name" "<name_in_boot_json>"
```
4. push repo changes
5. fetch the startup script and restart the computer
```
wget https://raw.githubusercontent.com/SuddenlyHazel/computer_craft/main/startup.lua
```
