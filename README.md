# Installation 
1. Install dependencies with the file from /deps, depending on your distro
2. Run ./build.sh in the root of the folder 
3. Run ./install.sh in /install

# Uninstallation 
1. Go to /install/uninstall.sh
2. Run it

# Building 
1. Run ./build.sh, assuming you have deps installed 

# Users Manual
To access the mode where you run scripts, press escape twice in rapid succession     
To get out of execution mode, press enter      
To extend the scripts avalible, modify /usr/local/bin/orca/lib/   
Scripts are ran based off of their filename. To create a command called 'example', create a file called example.lua   

# Commands
There are 6 commands created by default.    
1. clip -> usage : clip < text > || Copies text to the clipboard
2. exec -> usage : exec < cmd > || executes whatever is put in the input 
3. play -> usage : play < query > || downloads and plays from youtube, by whatever query is put in
4. remind -> usage : remind < time > < msg > || creates a notification at whatever time is specified, with the msg specified. Must use military time    
5. search -> usage : search < query > || uses the default browser to search a query or visit a website
6. playcache -> usage : playcache < query > || dowloads the selected video from youtube (selected from the query)

# Command examples 
1. clip || clip Hello world
2. exec || exec echo hi
3. play || play not like us kendrick lamar 
4. remind || remind 13 05 water the plants
5. search || search what is the time    
6. playcache || playcache DDevil system of a down