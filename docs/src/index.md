# Getting Started

## Overview

This exetension allows you to connect your  [Spree](https://github.com/spree/spree) store with [Gladly](https://www.gladly.com/) service. It allows Gladly agents to see basic information about Spree customers and their orders.

It adheres to the specification of a Gladly Lookup adapter as described [here](https://developer.gladly.com/tutorials/lookup).

## Installing the library

Add this line to your application's Gemfile:

```ruby
gem 'spree_gladly'
```

And then execute:

    $ bundle install

Next, you should run the installer:

    $ bundle exec rails generate spree_gladly:install

## Supported Spree versions

Supported Spree versions: `3.0`, `3.1`, `3.7`, `4.0`, `4.1`, `4.2`
