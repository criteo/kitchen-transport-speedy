# Kitchen::Transport::Speedy

This gem is transport plugin for kitchen. It signicantly improves file synchronization between workstation and boxes using archive transfer instead of individual transfers.

The transport only works where ssh works and requires `tar` to be present both on the workstation and in the box.

## Timing

On my workstation, on a already created linux box, from "kitchen converge" to the beginning of chef-client converges:
- with speedy\_ssh transport: 10 secs
- without speedy transport: 180 secs

Please note that cookbooks + roles + environments + databags represent around 5.5k files to transfer.

Tested with test-kitchen 1.8

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kitchen-transport-speedy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitchen-transport-speedy

## Usage

Modify your `.kitchen.yml` to include:

```
transport:
  name: speedy_ssh
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/criteo/kitchen-transport-speedy.

