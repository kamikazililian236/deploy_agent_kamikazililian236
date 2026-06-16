#!/bin/bash
zipping() {
echo " interrupt detected "
echo " cleaning up ..."
	if [ -d $project_dir ];then
	tar cf "${project_dir}_archive.tar.gz" "$project_dir"
	rm -rf "$project_dir"
	echo "Incompleted structure removed"
	fi
	exit 1
}
trap zipping  SIGINT



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

fi
cat > attendance_tracker_$project_dir/Helpers/config.json << EOF

{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF



read -p "Do you want to update the attendance thresholds? (y/n): " input
if  [ "$input" = "y" ]; then

    read -p "New warning threshold in %: " warning
    read -p "New failure threshold %: " failure
    sed -i  "s/75/$warning/" "$project_dir/Helpers/config.json"
    sed -i  "s/50/$failure/" "$project_dir/Helpers/config.json"
    echo " config.json updated with new thresholds"
fi
echo " Deployment successfully "

