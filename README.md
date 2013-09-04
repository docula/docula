# Docula - versioned documentation

You're already using git to manage your code. Why not use it to manage your docs too?

# Requirements
1. Ruby 1.9 (tested on **1.9.3p429** specifically). If you are using rbenv then this should be automatically used from `.ruby-version`

2. libmagic

    **OSX** - brew install libmagic
    <br />
    **Linux** - sudo apt-get install libmagic1 libmagic-dev

3. Bundler

    gem install bundler
   
4. An accessible MySQL instance. 
 
5. The mysql gem. On OS X, you'll typically need the following command:
  
    sudo ln -s /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/lib/libmysqlclient.18.dylib
    gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config

6. The remainder of the gems
  
    bundle

## Starting up
If you already have Ruby version 1.9+ (currently tested on version 1.9.3p429) then you're ahead of the game! If not, we recommend installing rbenv, ruby-build, and installing ruby through rbenv.

## Environment Configuration

### User-specific properties
In the cfg directory you will find example yaml files for your user-specific properties used by Docula. This is loaded by the `ENV['USER']` environment variable which should be whatever your username is that you are logged in with. Overview of the properties:

| Name | Potential Vals | Description |
| ----- | -------------- | ----------|
| `recreate` | **true/false** | Whether or not the database tables should be dropped and recreated when the app starts up
| `theme` | **'default' or some other theme** | Which folder name should be used by Docula to load css/js in the _public_ folder and  and Haml template files in the _views_ folder. This value is essentially appending onto the end of those 2 directories in the Sinatra config
| `data` | **YAML list** | Data that will be populated by Docula when `recreate` is true. The values here should correspond to the **docset** database table (see models/docset.rb)

### Database
Docula is currently tested with MySQL. It uses the database to determine which docsets it should load and where those docsets reside on your file system. You can configure your database connection 1 of 2 ways

#### 1. Renaming _database.yml to database.yml
After you rename this file you will need to modify the values to be suitable for your MySQL server. The values here should be pretty self-explanatory

#### 2. Fill out environment variables
These values are very similar to database.yml. If you do not have a database.yml file present, Docula will attempt to look at the following environment variables:
    ENV['docula.db.adapter']
    ENV['docula.db.host']
    ENV['docula.db.username']
    ENV['docula.db.password']
    ENV['docula.db.database']

#### OSX-specific
If you are using MySQL, ensure that your MySQL dylib is in /usr/lib (it's not by default) so that Ruby can get to it. You can add it easily with this symlink:

```console
sudo ln -s /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/lib/libmysqlclient.18.dylib
```

# Docsets
Each version of your documentation is referred to as a Docset. In the database, this includes the name of the docset, the branch that this particular docset is referring to (like 1.0, 2.3, etc) and an absolute path to a git repository on your local filesystem. This should be checked out at the correct branch (the same one configured in the database)

## URL Mappings

## Links
 * Talk about internal links (like Gollum)
 * Linking to docs and folders

# Attribution
This project is based on the [Riblits](https://github.com/Phrogz/riblits) project structure for Sinatra applications.
