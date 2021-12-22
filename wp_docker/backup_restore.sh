#!/bin/bash
### This bash script will restore the last Cloudways backups from the S3 bucket ###
"""

The following procedure goes like this:

1. The user will press the name the website s/he wants to upload from the backet's folder. 
## The name needs to be equal to the folder's name under the 's3://cloudaways-backups/mainwp/updraftplus/' path. ##

2. The script will copy the last backup files to the ./wp-content/updraft/ directory.

3. The script will execute restore WP from WP CLI with UpdraftPlus's plugin  
## https://updraftplus.com/wp-cli-updraftplus-documentation/ ##

4. The script will insert 'check_user' user for login authentication. The password will be shown on LastPass.
## the table's structure is:
+---------------------+---------------------+------+-----+---------------------+----------------+
| Field               | Type                | Null | Key | Default             | Extra          |
+---------------------+---------------------+------+-----+---------------------+----------------+
| ID                  | bigint(20) unsigned | NO   | PRI | NULL                | auto_increment |
| user_login          | varchar(60)         | NO   | MUL |                     |                |
| user_pass           | varchar(255)        | NO   |     |                     |                |
| user_nicename       | varchar(50)         | NO   | MUL |                     |                |
| user_email          | varchar(100)        | NO   | MUL |                     |                |
| user_url            | varchar(100)        | NO   |     |                     |                |
| user_registered     | datetime            | NO   |     | 0000-00-00 00:00:00 |                |
| user_activation_key | varchar(255)        | NO   |     |                     |                |
| user_status         | int(11)             | NO   |     | 0                   |                |
| display_name        | varchar(250)        | NO   |     |                     |                |
+---------------------+---------------------+------+-----+---------------------+----------------+
##

""" 2&>/dev/null

echo -e "\n\nHello! Please give the parameters that you've chose for your wp site.\n"

## Take the users' WP username ##
read -p "Enter your WP username that you've creted: " WP_USERNAME

if [ -z "$WP_USERNAME" ]
then
    # Exit the script if there's no input from his username
    echo "You have to input your usermame.. Please try again"
    exit 1
fi

## Take the users' WP password ##
echo -n "Enter your WP password that you've creted:"
read -s WP_PASSWORD 
echo ""

if [ -z "$WP_PASSWORD" ]
then
    # Exit the script if there's no input from his password
    echo "You have to input your password.. Please try again"
    exit 1
fi

## Take the users' email addree ##
read -p "Enter your chosen email address: " EMAIL_ADDRESS

if [ -z "$EMAIL_ADDRESS" ]
then
    # Exit the script if there's no input from his email address
    echo "You have to input your email address.. Please try again"
    exit 1
fi


## Take an input of the s3 bucket from the user ##
# Take the input and put it into a 'S3_BUCKET_FOLDER' param #
echo -e "\n\n\nThank you! What is the bucket's folder name of the updraftplus backup on S3?
\nYou can find the bucket's folder name under the 's3://cloudaways-backups/mainwp/updraftplus/' folder.\n\n"

read -p  "Bucket's folder name: " S3_BUCKET_FOLDER
S3_BUCKET_PATH="s3://cloudaways-backups/mainwp/updraftplus/$S3_BUCKET_FOLDER"

# Verify that the input validate - compare the name that has been chosen with the s3 bucket's subfolder #
bucket_existen_state=$( aws s3 ls $S3_BUCKET_PATH | grep -w $S3_BUCKET_FOLDER)
if [ -z "$bucket_existen_state" ]
then
    # If it does not, send a message to user and break #
    echo -e "\n\n$S3_BUCKET_PATH path is not exists... try again\n\n"
    exit 1
fi

## Ask from the user to choose the date of the backup before recovering. If there's no existen object with this date, tell it to the user ##
date_state=false
while ! "$date_state"
do
    read -p "Please provide the date you'll like to recover from.. Acceptible value is yyyy-mm-dd: " chosen_date
    if [[ $chosen_date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
    then
        # If the format accurate, search objects that begin with 'backup_$chosen_date' string #
        object_search_keyword="backup_$chosen_date"
        object_search_query="$S3_BUCKET_PATH/$object_search_keyword"
        object_search_state=$( aws s3 ls $object_search_query)
        if [ -z "$object_search_state" ]
        then
            # If there's no such object, ask again the date of the backup #
            echo -e "\n\nThere is not backup with your date... try again\n\n"
        else
            # If the objects have been found, break this while loop
            date_state=true
        fi
    else
        # If the date format is not accurate, send a message to user and ask again the date of the backup #
        echo -e "\n\nYour date format: '$chosen_date' is not allowed.. Try typing date like '2019-01-01'\n\n"
    fi
done


## Initial Script's variables ##
export wp_db_name=$WORDPRESS_DB_NAME
export wp_db_username=$WORDPRESS_DB_USER
export wp_db_pass=$WORDPRESS_DB_PASSWORD
export updraftplus_account_user=$UPDRAFTPLUS_ACCOUT_USER
export updraftplus_account_pass=$UPDRAFTPLUS_ACCOUT_PASS


## Copy the AWS Cloudways backup objects to the 'wp-content/updraft/' directory ##

# Copy the new backup files (Which the user has been chosen) to the updraft directory #
aws s3 cp $S3_BUCKET_PATH ../html/wp-content/updraft/ --exclude "*" --include "*$chosen_date*" --recursive
echo -e "\nThe backup from the date you've chosen is ready to be restored\n"

# Update Updraft's plugin #
wp plugin update updraftplus --allow-root --path='../html'
# Connect to Updraft's account #
wp updraftplus connect --email=$updraftplus_account_user --password=$updraftplus_account_pass --allow-root --path='../html'
echo -e "\n\nYou have been connected to the UpdraftPlus's premium account\n\n"

## Restore WP with WP CLI by using the UpdraftPlus's plugin ##
# Get the backup ID from the existing backups of the UpdraftPlus's plugin and restore the backup # 
export backup_id=$(wp updraftplus rescan-storage local --allow-root --path='../html' | tail -n1 | awk -F "[" '{print $2}' | awk -F "]" '{print $1}') 2&>/dev/null
wp updraftplus restore $backup_id --allow-root --path='../html'
# the restore function sends a message to the user that The restore has been done


## Insert User Admin user name to the 'wp_users' table and Update redirections to this Domain Name ##
# First, Change the site URL to the domain's name #
export update_redirections="update wp_options set option_value = 'http://localhost:8000/' where option_name = 'siteurl';
update .wp_options set option_value = 'http://localhost:8000/' where option_name = 'home';"
mariadb --host db --user="$wp_db_username" --password="$wp_db_pass" --database="$wp_db_name" --execute="$update_redirections"

# Next, check wether the user's wp user exists. If it does, delte it #
# Same with a user's email address #

user_existen_check_login=$(mariadb --host db --user="$wp_db_username" --password="$wp_db_pass" --database="$wp_db_name" --execute="Select ID FROM wp_users where user_login='"$WP_USERNAME"';") >/dev/null
user_existen_check_email=$(mariadb --host db --user="$wp_db_username" --password="$wp_db_pass" --database="$wp_db_name" --execute="Select ID FROM wp_users where user_email='"$EMAIL_ADDRESS"';") >/dev/null

if [ -n "$user_existen_check_login"  ]
then
        wp user delete $user_existen_check_login --yes --allow-root --path='../html'

fi
if [ -n "$user_existen_check_email" ]
then
        wp user delete $user_existen_check_email --yes --allow-root --path='../html'

fi

#  create the user's wp username and set its permissions for the WP console of the site
echo -e "\nCreating user '"$WP_USERNAME"' for login\n"
wp user create "$WP_USERNAME" "$EMAIL_ADDRESS" --role='administrator' --user_pass="$WP_PASSWORD" --allow-root --path='../html'

# Remove the old backups from the updraft directory  # 
echo -e "\nRemoving backup dumbs from the UpdraftPlus plugin..\n"
rm -rf ../html/wp-content/updraft/*old
rm -rf ../html/wp-content/*old
echo -e "\nUpdraftPlus plugin's folder has been cleaned.\n"


# Activate english language as the core lan on WP
wp language core install en_US --activate --allow-root --path='../html'
wp site switch-language en_US  --allow-root --path='../html'
wp user meta update "$WP_USERNAME"  locale en_US --allow-root --path='../html'

echo -e "\n\n\nEverything has been set up!\n\n\n"

