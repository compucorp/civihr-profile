## Introduction

This Drupal profile was created to make the CiviHR installation as easy and simple as possible. In this repo, you'll find two pieces that are responsible for making this happen:

- The `civihr.make.yml` file, which lists all of the CiviHR dependencies and makes it possible to download everything with a simple `drush make` command
- The profile itself (`civihr.profile`, `civihr.module`, `civihr.info` and the `civihr.install` files), which is responsible to encapsulate all the logic necessary to setup the site which was built using the make file.

> **What is a Drupal profile?**
> 
> A profile is a special type of Drupal module that hook into the Drupal site installation, allowing the module to perform various setup/configuration tasks while the site is being installed. Here is a list of some of the things the CiviHR profile does:
> 
> - Make sure only the blocks, node types and vocabularies used by CiviHR are created
> - Optionally create demo users, that can be used by people who only want to try CiviHR out
> - Make sure all the dependencies are installed in the correct order
> - Set up all the necessary themes
>
> The profile also makes it possible to install CiviHR using your browser, via a web interface, instead of using the `drush site-install` command.
> 
> For more information about Drupal profiles, please check the [official documentation](https://www.drupal.org/docs/7/creating-distributions).

## Requirements

- Drush 8.x

## Usage

### Downloading dependencies

First, you'll need to create a new site by downloading all the dependencies. To do that, you can use the `build-dist.sh` script:

```
$ ./build-dist.sh
```

That script, will basically run this `drush make` command:

```
drush make build-civihr-package.make.yml site
```

Which will result in a new CiviHR site built in the `site` folder. This site is now ready to be installed.

> **Why `build-civihr-package.make.yml` instead of `civihr.make.yml`?**
> 
> The `civihr.make.yml` file contains only the CiviHR dependencies. The `build-civihr-package.make.yml` file, contains the "definition" of a CiviHR site, which is a Drupal site + the CiviHR profile (that includes all of the CiviHR dependecies).
>
> In practical terms, if you run `drush make civihr.make.yml`, all the dependencies will be downloaded, but the site will not include the CiviHR profile and it will not be possible to proceed with the installation. Differently, when using `build-civihr-package.make.yml`, the site will also include the profile, which will make it possible to go ahead with the installation.

#### Downloading dependencies for a development site

The CiviHR code is kept in multiple different git repositories. When downloading that code, the `build-dist.sh` script will make a shallow copy of these repos. That is, it will only download the latest version of the code available instead of creating a working copy of the repository. This is great for people that only want to use CiviHR, as it will drastically reduce the download size, but it's not ideal for developers. 

To create a development site, the `build-dev.sh` should be used instead. It executes a `drush make` command very similar to the one used by the `build-dist.sh` script, but it will use the `civihr-dev.make.yml` to override some options in the original make file, and tell the make command to create working copies while cloning the repos.

### Installing the site

Now that you have all the dependencies in place, you can go ahead with the installation, which can be done either via a web interface or using `drush site-install`.

### Installation using `drush site-install`

For this installation method, you'll first need to manually create an empty database which will be used by CiviCRM. With that done, you can run the `site-install` command:

```
$ drush site-install -y civihr --locale=en \
--db-url=mysql://<db_user>:<db_password>@<db_host>:<db_port>/<drupal_db_name> \
--account-name="<super admin username>" \
--account-pass="<super admin password>" \
--account-mail="<super admin email>" \
--site-name="<site name>" \
database_configuration.drupal.database=<drupal_db_name> \
database_configuration.drupal.username=<db_user> \
database_configuration.drupal.password=<db_user> \
database_configuration.civicrm.database=<civicrm_db_name> \
database_configuration.civicrm.username=<db_user> \
database_configuration.civicrm.password=<db_user>
```

Notes:
- The CiviCRM database cannot be the same database as Drupal's.
- Both databases must be in the same host
- It's possible to have a different user for each database, but both users must have access to both databases.

Here is an example:

```
$ drush site-install -y civihr --locale=en \
--db-url=mysql://root:root@127.0.0.1:3306/civihr_drupal \
--account-name="admin" \
--account-pass="admin" \
--account-mail="admin@example.org" \
--site-name="CiviHR" \
database_configuration.drupal.database=civihr_drupal \
database_configuration.drupal.username=root \
database_configuration.drupal.password=root \
database_configuration.civicrm.database=civihr_civicrm \
database_configuration.civicrm.username=root \
database_configuration.civicrm.password=root
```

> **Important**
>
> You MUST execute the `site-install` command from the site root folder. If you've created the site using one of the bash scripts in this repo, that folder will be `site`.

### Installation using the web-interface

For this method, you'll need to have a virtual host in your webserver pointing to the site you've created with the make command. It's out of the scope of this documentation to describe how to configure your webserver, but keep in mind that you'll need URL rewriting enabled.

Besides the webserver configuration, it is also necessary to manually create two empty databases: one for Drupal and another one for CiviCRM.

With everything ready, all you'll have to do is point your browser to the configured website and you'll see an installation wizard very similar to the regular Drupal one. Follow each of the steps and, at the end, you'll have a working site.

## Known issues and limitations

- Regardless of the installation method, the CiviCRM database needs to be manually created.
- There's some duplication in the drupal database params passed to the `site-install` command.
- The `build-dev.sh` script uses a tarball to download CiviCRM. This results in a site that is not 100% suitable for development, as the tarball misses some classes and scripts necessary for our development workflow
- It is not possible to tell `build-dev.sh` which branch it should download the code from. This happens because it builds the site based on the dependencies in the .yml file and it's not possible to pass params to it.
