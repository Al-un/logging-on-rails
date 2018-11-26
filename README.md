# Logging-on-Rails

This repository lists multiple logging configuration used in my [Logging-on-Rails article](https://medium.com/@Al_un/logging-on-rails-5-hide-and-seek-with-formatting-readibility-and-parsing-1c2014411540).

## Start

Start by cloning this repository:
```
git clone https://github.com/Al-un/logging-on-rails.git
```
and install the required dependencies:
```
bundle install
```

This repositories uses Sqlite3 which is known to have troubles under Windows. It
is recommended to build the native gem. This [StackOverflow question](https://stackoverflow.com/a/16023062/4906586)
is a good starting point.

Select a configuration below in `.env` file:
```
LOGGER_CONFIG = 'FINAL'
```
and run it:
```
rails server
```

## Configuration

At the exception of `logging-rails` gem, all gems are included and the configuration
is set at `.env` level. Valid values for `LOGGER_CONFIG` are:

- `STANDARD_V1`
    Basic ruby logger
- `STANDARD_V2`
    Adding Log level and tagged logging
- `STANDARD_V3`
    Custom console format
- `STANDARD_V4`
    Custom console and file logging
- `LOGGING_V1`
    Standard logging library
- `LOGGING_V2`
    Logging rails with custom colorization. You will need to uncomment `gem 'logging-rails'`
    in your Gemfile. Don't forget to comment it back if you use another configuration
- `LOGRAGE_V1`
    Lograge with default Ruby logger
- `LOGRAGE_V2`
    Lograge with lograge-sql extension
- `OUGAI_V1`
    Simple Ougai configuration
- `LOGGLY`
    Enable a simple Loggly push. You will need a [Loggly](https://www.loggly.com) 
    account and get a Loggly token. Once you got the token, add it in a *.env* file 
    under the key `LOGGLY_TOKEN`. I use *.env.local* file for my loggly token
- `FINAL`
    My personal final configuration:
    - *Ougai* coupled with [*Ougai-formatters-customizable* extension](https://github.com/Al-un/ougai-formatters-customizable)
    - *Lograge* with *Lograge-SQL* extension
    - *Loggly* via the *Logglier* gem