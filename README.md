# restore s3 backups of WP with Docker project

## The purpose of the project
```
* The purpose of the project is to restore Updraft's backups from the "cloudaways-backups" S3 bucket to localhost via Docker

* The user will choose the title, username, password and an email address by installing the wp site.Then, he'll restore the backup with a script

* The website will change the admin console language to english 
```

## **Follow the pre-requirements for the project, and then follow the steps below.**

## Prerequiremnts for the project
```
* Make sure you have updraft's credentials on LastPass

* Make sure you have access to the "cloudaways-backups" S3 bucket. The path is [here](https://s3.console.aws.amazon.com/s3/buckets/cloudaways-backups?prefix=mainwp/updraftplus/&region=eu-central-1).

* Change directory to this current folder ("restore_s3_backups" directory)

* Copy the '.env.example' file to an '.env' file and fill the parameters as required. 
 
* Make sure you have updraft's credentials on LastPass

* Leave your 8080, and 8000 ports open.
```

## Step 1 -- Start the project

> docker-compose up -d --build --no-deps

> docker-compose exec wordpress init.sh

## Step 2  -- Get ready with Updraftplus plugin
```
1. Enter to your [local server](http://localhost:8000) and install wordpress.

2. Follow the instructions [here](https://updraftplus.com/support/installing-updraftplus-premium-your-add-on/) to use the Premium version of Updraftplus. 

- Uncheck the 'Add this website to UpdraftCentral' box 
```



## Step 3 - Execute the restore script 

> docker-compose exec wordpress /var/www/Script/backup_restore.sh

**Then you should follow the scripts instructions**

## Get into phpmyadmin
For phpmyadmin press [here](http://localhost:8080/).


## Final Step - Close the project
**After you done -  remove containers, db volume and old files**
> docker-compose down

> docker volume rm restore_s3_backups_db_data

**On Linux**
> ** Delete wp_files/* content **

> rm -rf wp_files/*

> ** Delete logs/mysql/* content **

> rm -rf logs/mysql/*

> ** Delete logs/wordpress/* content **

> rm -rf logs/wordpress/*

**On Windows**

**Delete wp_files/* content**

> &cmd.exe /c rd /s /q .\wp_files\wp-content\; Get-ChildItem -Path "wp_files" -Recurse | Remove-Item -force -recurse; New-Item -ItemType "file" -Path "./wp_files/.gitkeep"

**Delete logs/mysql/* content**

> get-childitem .\logs\mysql\* -include *.* -recurse | remove-item -Force -Recurse; Remove-Item .\logs\mysql\* -Force -Recurse

**Delete logs/wordpress/* content**

> get-childitem .\logs\wordpress\* -include *.* -recurse | remove-item -Force -Recurse; Remove-Item .\logs\wordpress\* -Force -Recurse


# Common errors & commands

## Common Errors ##
**"There has been a critical error on this website. Please check your site admin email inbox for instructions."**
```
Deactivate plugins with [this](https://wordpress.org/support/article/faq-troubleshooting/#how-to-deactivate-all-plugins-when-not-able-to-access-the-administrative-menus) guide. 
```

**"Error message: Could not move the files into place. Check your file permissions."**
```
Finish the project by using the "final step" and then re-create it by usign "step 1".
```

## Common Docker commands
**Rebuild single container**
> docker-compose up -d --no-deps --build <service_name>

**Enter the container**
> docker-compose exec [service name] bash
