# Scry

Scry provides a mechanism for an application to use divination to discover knowledge about dependent services and configuration.

External, or environmental, configuration has often been handled with shell environment variables. However, managing environment variables can become cumbersome when moving a project around different teams of developers and different run environments. Common tools like init scripts, sudo, and application servers will often strip environment variables before executing the application.

Scry allows the project to be conditionally configured using configuration files and pre-defined defaults. This enables tools like chef or capistrano that have knowledge of a system as a whole to create configuration files instructing an application how to find and interact with external systems, and optionally set environmental overrides.

Scry makes discovering configuration problems easy.

## Installation

Add this line to your application's Gemfile:

    gem 'scry'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scry

## Usage

### Create a Scryfile

Create a Scryfile in your projects root. This file tells scry how to locate and merge configuration files, and defines required configuation and any available default values.

```ruby
# A sample Scryfile.
# More info at https://github.com/ridecharge/scry#readme

# Ordered list of configuration sources, the last source listed takes
# precedence over previous sources You probably don't want any of these in your
# project source control. Instead, define defaults below.
source "$HOME/.ridecharge/globals.yml"
source "$HOME/.ridecharge/scry.yml"
source "config/globals.yml"
source "config/scry.yml"

# Configuration requirements and default values
namespace 'myapp' do
  param 'domain',
    :type => String,
    :description => "Canonical domain name for the RC service"

  param 'memcached',
    :default => [ 'localhost:11211' ],
    :type => Array,
    :description => "List of memcached servers to use"

  namespace 'web' do
    param 'hostname',
      :type => String,
      :description => "Internal hostname for the RC service"
  end

  namespace 'mail' do
    param 'method',
      :default => 'sendmail',
      :type => String,
      :description => "What ActionMailer method to use (sendmail|smtp)"
    param 'sendmail',
      :default => '/usr/bin/sendmail',
      :type => String,
      :description => "Location of the sendmail binary"
  end
end
```

### Rails

Create config/initializers/scry.rb

```ruby
require 'scry'

GlobalConfig = Scry.init
```

### Other ruby apps

TODO: Describe how to initialize scry in other ruby apps

### Fetching data from the Scry object

Configuration values can be extracted from Scry in several ways.

If you've assigned the result of Scry.init to an object, you can access the configuration like any other ruby hash.

```ruby
cfg = Scry.init
app_domain = cfg['myapp']['domain']
```

You can also use accessor methods on the Scry object to find the value of configration data.

```ruby
app_domain = Scry.fetch('myapp')

# or...

app_domain = Scry.fetch('myapp').fetch('domain')
```

### Inspecting the results of a Scry

```ruby
app_domain = Scry['myapp']['domain']

puts app_domain
# "www.example.com"
```

or

```
rake scry

# and/or

rake scry:view
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
