# flowerfarm

The Ohio Barn Flower Farm, TOC:

[Docs](#Docs)

[Wordpress](#Wordpress)

---

## Docs

This repo uses [mkdocs](https://www.mkdocs.org/) ([help](https://mkdocs.readthedocs.io/en/0.10/)) and [github pages](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/) to host content at:

https://tonygilkerson.github.io/flowerfarm/

### Develop

```bash
cd OpsDoc
mkdocs serve
# Edit content and review changes here:
open http://127.0.0.1:8000/
```

### Publish

```bash
cd OpsDoc
mkdocs build --clean
mkdocs gh-deploy
open https://tonygilkerson.github.io/flowerfarm/
```

## Wordpress

### Sandbox Setup

* Download from https://wordpress.org/download/

### Development

```bash
docker-compose up
open http://localhost:8080/
```

### Publish to Bluehost

```bash
ssh ohiobar1@ftp.ohiobarnflowerfarm.com 

cd wordpress
scp -r duplicator/* ohiobar1@ftp.ohiobarnflowerfarm.com:./www
```

### Reference

[wordpress development workflow](https://www.technouz.com/4613/ultimate-wordpress-website-development-workflow/)

### Moving between Staging and Prod

* todo - document the make file

### Moving between Staging and Prod (old)


* Please create a new database and user for your staging website and update the details in wp-config file in your staging folder. 
* Then update the home and site URL of the staging website as http://ohiobarnflowerfarm.com/staging in wp-options option in your new database. 
* Once you finish the website you can move the staging files to your main website files and then update the site URL as  http://ohiobarnflowerfarm.com/ in your database 
* You can create the new database and user in My SQL database option
* Please create user and database and give all priviliiages.

Since you are using Ubuntu, all you need to do is just to add a file in your home directory and it will disable the mysqldump password prompting. This is done by creating the file ~/.my.cnf (permissions need to be 600)

```bash
[mysqldump]
user=ohiobar1_dbuser
password=<pwd>

[mysql]
user=ohiobar1_dbuser
password=<pwd>
```

### Copy from Prod to Sandbox

* Go to the duplicator page in prod `https://ohiobarnflowerfarm.com/prod/wp-admin/admin.php?page=duplicator`
* Create a duplicator package
  * db: ohiobar1_prod
  * db user: ohiobar1_dbuser
  * use `make dsp-db-info` for password
* Take the defaults and then same in `duplicator-work/flower-snapshot-YYYYMMDD`
* run `docker-compose up`
* copy installer and package zip into web root

  ```bash
  cp duplicator-work/flower-snapshot-YYYYMMDD/* wordpress/
  mv wordpress/wp-config.php wordpress/wp-config.php.back
  ```
* run `docker-compose up`
* open `http://localhost:8080/installer.php` and complete the wizard


