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

cat > attendance_tracker_$project_dir/Helpers/assets.csv << EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

cat > attendance_tracker_$project_dir/Helpers/attendance_checker.py << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":

    run_attendance_check()

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

