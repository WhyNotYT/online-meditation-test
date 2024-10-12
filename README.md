# Online-Meditation

Research and Development Project - Group 7

THIS IS A COURSE WORK, NOT FOR PRODUCTION.


# Updated for Openshift Deployment

## Deploying on Rahti:

To deploy this app to Rahti, you need to deploy a MySQL database and this repo.

It has been tested with this MySQL Image:
https://catalog.redhat.com/software/containers/rhel9/mysql-80/61a60915c17162a20c1c6a34

### Deploying MySQL
- Open Rahti Project -> Add
- Go to Container Images
- Use this URL: registry.redhat.io/rhel9/mysql-80:1-330.1726663407
- Advanced Deployment Options -> Environment Variables
- Add these environment variables
  - MYSQL_USER=laravel
  - MYSQL_PASSWORD=laravel_password
  - MYSQL_DATABASE=laravel_db
- Wait for it to finish deploying.
- Navigate to Pod details
- Find the Pod IP (Looks like this: 172.30.178.174)

### Deploying Laravel App
- Open Rahti Project -> Add
- Go to Import from git
- Use the URL of this repo
- Go to environment variables section
- Add this:
    - DB_HOST=[The Pod IP you got from earlier]
- Create
- Go to topology and find and monitor the build logs
- It might take up to 15 mins for the build to complete
- Go to the container's terminal (Select Pod from Topology->View Logs->Terminal)
- type "nano .env"
- Update APP_URL and ASSET_URL with the new URL
	- APP_URL=[target url]
    - ASSET_URL=[target url]
- Save and Exit
- Run these in the Terminal:
    - php artisan config:clear
    - php artisan cache:clear
    - php artisan view:clear

## Debugging
###  If there's Bad Gateway or Server Error
- Go to the container's terminal (Select Pod from Topology->View Logs->Terminal)
- Run these:
  - php artisan key:generate
  - php artisan session:table
  - php artisan migrate
  - php artisan config:clear
  - php artisan cache:clear

### If registration doesn't work
- Run these in the container's terminal:
    - php artisan tinker
    - \Spatie\Permission\Models\Role::create(['name' => 'user', 'guard_name' => 'web']);
    - php artisan config:clear
    - php artisan cache:clear
    - php artisan permission:cache-reset