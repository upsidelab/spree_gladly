# Running tests

````
bundle exec rake test_app
bundle exec rake spec
````

To run specific test:
````
bundle exec rspec spec/controllers/spree/api/v1/customers_controller_spec.rb
````

Testing against specific Spree version:
````
export BUNDLE_GEMFILE=gemfiles/spree_3_7.gemfile
bundle install
bundle exec rake test_app
bundle exec rake spec
````