# Docula - versioned documentation

You're already using git to manage your code. Why not use it to manage your docs too?

## Environment Configuration
You will need 

## Starting up
If you already have Ruby version 1.9+ (currently tested on version 1.9.3p429) then you're ahead of the game!

## Environment Configuration

### OSx-specific
If you are using MySQL, ensure that your MySQL dylib is in /usr/lib (it's not by default) so that Ruby can get to it. You can add it easily by adding this symlink:

```console
sudo ln -s /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/lib/libmysqlclient.18.dylib
```

## Attribution
This project is based on the [Riblits](https://github.com/Phrogz/riblits) project structure.
