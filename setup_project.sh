 #!/bin/bash

echo "Start deploying."
echo "Confirming if it python 3 is installed."

if python3 --version;then
	echo "Python3 is installed"
else
	echo "Python3 doesn't exist"
fi

read -p "Enter the project name: " input 
project_dir="attendance_tracker_${input}"
if [ -d $project_dir ];then
   echo "Directory already exists"

else

    mkdir -p "$project_dir/Helpers"
    mkdir -p "$project_dir/reports"

echo "Folders created."
    mv attendance_checker.py "$project_dir/"
    mv assets.csv            "$project_dir/Helpers/"
    mv config.json           "$project_dir/Helpers/"
    mv reports.log           "$project_dir/reports/"

echo "Files moved"

fi

read -p "Do you want to update the attendance thresholds? (y/n): "input
if  [ "$choice" = "y" ]; then

    read -p "Enter warning threshold in %: "warning
    read -p "Enter failure threshold %: " failure
    sed -i  "s/75/$warning/" "$name/Helpers/config.json"
    sed -i  "s/50/$failure/" "$name/Helpers/config.json"

echo " config.json updated with new thresholds"

fi
    
echo " Deployment successfully "

