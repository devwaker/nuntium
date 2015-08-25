

# Installing #

**Important: Nuntium currently runs only on unix-based systems.**

  1. Download the source code as described here: http://code.google.com/p/nuntium/source/checkout
  1. Download and install the [required libraries](#Required_libraries.md)
  1. Run the usual rake comamnds:
```
rake db:create
rake db:migrate
rake db:seed
```

## Required libraries ##

Nuntium uses:
  * [RabbitMQ](http://www.rabbitmq.com/) for it's background job processing
  * [Memcached](http://memcached.org/) for improved performance
  * [Nokogiri](http://nokogiri.org) for fast XML parsing
  * [God](http://god.rubyforge.org/) for process monitoring
  * [ci\_reporter](http://caldersphere.rubyforge.org/ci_reporter/) for continuous integration
You will need to install these before running Nuntium.

### RabbitMQ ###

  1. Follow the [installation instructions on the RabbitMQ site](http://www.rabbitmq.com/install.html)
  1. Run the RabbitMQ server
  1. Once you have it installed, run the following command on your Nuntium directory:
```
sudo rake rabbit:prepare
```
> This will create the RabbitMQ user and vhost specified in the `config/amqp.yml` file.

Make sure you have RabbitMQ running before running Nuntium. You can restart the RabbitMQ server by issuing this command:

```
sudo /etc/init.d/rabbitmq-server restart
```

### Memcached ###

Follow the [installation instructions on the Memcached site](http://code.google.com/p/memcached/wiki/NewStart)

Make sure you have Memcached running before running Nuntium:

```
memcached -d
```

### Nokogiri ###

Follow the [installation instructions on the Nokogiri site](http://nokogiri.org/tutorials/installing_nokogiri.html)

### God ###

```
sudo gem install god
```

### ci\_reporter ###

```
sudo gem install ci_reporter
```

# Running #

Currently god starts up some mongrel instances, so you will need to:

```
gem install mongrel
```

  1. Start god:
```
sudo god -c config/nuntium_development.god
```
  1. Point your browser to `http://localhost:3000`

The previous instructions are for running Nuntium in development mode. For production mode you would need to run all the rake tasks with `RAILS_ENV=production` before the command text (including the ones for [setting up RabbitMQ](#RabbitMQ.md)), like
```
RAILS_ENV=production rake db:create
```

To start god in production mode:

```
sudo god -c config/nuntium.god
```

# Running the tests #

If you run the tests and they pass there is a very high chance that Nuntium is correctly installed on your system. ;-)

  1. Run the RabbitMQ rake task for test environment:
```
RAILS_ENV=test rake rabbit:prepare
```
  1. Prepare the database for testing:
```
rake db:test:prepare
```
  1. Run the tests:
```
rake test
```

# FAQ #

## You get `eventmachine not initialized: evma_install_oneshot_timer` ##

That probably means you don't have [RabbitMQ up and running](#RabbitMQ.md).

# More help #

Please send a message to our [mailing list](http://tech.groups.yahoo.com/group/nuntiumusers/).