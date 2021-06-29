# SpreeGladly
[comment]: <> (add Travis status build badge when repo became public)

## Overview
This exentension allows you to connect your  [Spree](https://github.com/spree/spree) store with [Gladly](https://www.gladly.com/) service.

Supported Spree versions: `3.0`, `3.1`, `3.7`, `4.0`, `4.1`, `4.2`

**Table of contents:**
- [Installation](#installation)
- [Configuration](#configuration)
- [Customization](#customization)
- [Usage](#usage)
- [Sandbox App](#setup-sandbox-environment)
- [Testing](#testing)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spree_gladly'
```

And then execute:

    $ bundle install

Next you should run the installer:

    $ bundle exec rails generate spree_gladly:install


## Configuration

### Spree Store side:

After installation, you will find in `config/initializers/spree_gladly.rb` directory the below file:

```ruby
SpreeGladly.setup do |config|
  # The key used to validate the Gladly lookup request signature.
  # We recommend using a secure random string of length over 32.
  config.signing_key = '<%= SecureRandom.base64(32) %>'

  # You can change serializer on your own
  config.basic_lookup_presenter = Customer::BasicLookupPresenter
  config.detailed_lookup_presenter = Customer::DetailedLookupPresenter

  # The request's timestamp is validated against `signing_threshold` to prevent replay attacks.
  # Setting this value to `0` disables the threshold validation.
  # Default is `0`.
  # config.signing_threshold = 5.minutes
end

```

where you are able to set the preferences:

- **signing_key:** *cryptographic key to sign every request to your lookup service*
- **signing_threshold:** *time value to prevent replay attacks ( default: 0 )*
- **basic_lookup_presenter:** *presenter which is responsible for basic lookup `results` payload ( default: Customer::BasicLookupPresenter )*
- **detailed_lookup_presenter:** *presenter which is responsible for detailed lookup `results` payload ( default: Customer::DetailedLookupPresenter )*

You can also set `signing_key` and `signing_threshold` via the admin dashboard in your Spree instance. To do that, open `Gladly Settings` in the `Configurations` section.

<img width="1436" alt="gladly_settings_admin_dashboard" src="https://user-images.githubusercontent.com/1455599/123083627-83c99400-d420-11eb-87ca-c1c5e20583d9.png">


### Gladly Service side:

Provide to your agent:
- lookup endpoint (  `https://example-spree-store.com/api/v1/customers/lookup` ), where `https://example-spree-store.com` is **your** Spree store URL.
- signing_key 

## Customization

Within `spree_gladly` gem you are able to customize response payload i.e [detailed lookup response](#detailed-lookup) by replacing `Customer::DetailedLookupPresenter` in `config/initializers/spree_gladly.rb` initializer file with your own.

Please consider below example:

```ruby
class GladlyCustomersPresenter
  include Spree::Core::Engine.routes.url_helpers # this is important if you want to use Spree routes

  def initialize(resource:)
    @resource = resource
  end

  def to_h
    return {} unless resource.customer.present?

    detailed_payload
  end

  private

  attr_reader :resource

  def detailed_payload
    [
      {
        externalCustomerId: resource.customer&.id.to_s,
        name: address&.full_name,
        address: address.to_s&.gsub('<br/>', ' '),
        emails: emails,
        phones: phones,
        orders: orders
      }
    ]
  end
  ...
end
```

`config/initializers/spree_gladly.rb`

```ruby
SpreeGladly.setup do |config|
  # ...
  
  config.basic_lookup_presenter = Customer::BasicLookupPresenter
  config.detailed_lookup_presenter = GladlyCustomersPresenter

  # ...
end
```

**!!! Important !!!**

If you would like to resign from `to_h` or change `initialize(resource:)` method, you have to override  `Spree::Api::V1::CustomersController#serialize_collection` to do that, please follow by this [guide](https://guides.spreecommerce.org/developer/customization/logic.html#extending-controllers)

`app/controllers/spree/api/v1/customers_controller.rb`

```ruby
def serialize_collection(type:, collection:)
  presenter = {
    detailed: SpreeGladly::Config.detailed_lookup_presenter.new(resource: collection),
    basic: SpreeGladly::Config.basic_lookup_presenter.new(resource: collection)
  }[type]

  { results: presenter.to_h }
end
```

## Usage

### Example payloads

All fields in `response` payload are retrieved from [Spree::Order](https://guides.spreecommerce.org/developer/internals/orders.html)  and related models. 

ENDPOINT: `https://example-spree-store.com/api/v1/customers/lookup`
### Basic Lookup

**request payload:**
```json
{
  "lookupLevel":"BASIC",
  "uniqueMatchRequired":false,
  "query":{
    "emails":"customer@example.com",
    "phones":[
      "666-666-666"
    ]
  }
}
```

**response payload:**

```json
{
  "results":[
    {
      "externalCustomerId":"1",
      "name":"James Bond",
      "email":"customer@example.com",
      "phone":"666-666-666"
    }
  ]
}
```

### Detailed Lookup

**request payload:**

```json
{
  "lookupLevel":"DETAILED",
  "uniqueMatchRequired":true,
  "query":{
    "emails":"customer@example.com",
    "phones":[
      "666-666-666"
    ],
    "externalCustomerId":"4"
  }
}
```

**response payload:**
```json
{
  "results":[
    {
      "externalCustomerId":"4",
      "name":"James Bond",
      "address":"James Bond Baker Street 007 London, AK 00021 United Kingdom",
      "emails":[
        {
          "original":"customer@example.com"
        }
      ],
      "phones":[
        {
          "original":"666-666-666"
        }
      ],
      "customAttributes":{
        "lifetimeValue":"$142.97",
        "totalOrderCount":"2"
      },
      "transactions":[
        {
          "type":"ORDER",
          "orderStatus":"complete",
          "orderNumber":"R185194841",
          "products":[
            {
              "name":"Flared Midi Skirt",
              "status":"fulfilled",
              "sku": "SKU-1",
              "quantity":"1",
              "unitPrice":"$78.99",
              "total": "$78.99",
              "imageUrl":""
            }
          ],
          "orderLink":"https://example-spree-store.com/admin/orders/R185194841/edit",
          "note":"",
          "orderTotal":"$83.99",
          "createdAt":"2021-06-21T10:29:43.881Z"
        },
        {
          "type":"ORDER",
          "orderStatus":"complete",
          "orderNumber":"R461455233",
          "products":[
            {
              "name":"3 4 Sleeve T Shirt",
              "status":"fulfilled",
              "sku": "SKU-2",
              "quantity":"2",
              "unitPrice":"$26.99",
              "total": "$53.98",
              "imageUrl":"https://example-spree-store.com/images/sample_picture.jpg"
            }
          ],
          "orderLink":"https://example-spree-store.com/admin/orders/R461455233/edit",
          "note":"",
          "orderTotal":"$58.98",
          "createdAt":"2021-06-21T10:34:10.262Z"
        }
      ]
    }
  ]
}
```

## Setup sandbox environment

1. Deploy Spree store on hosting provider ( [heroku example](https://guides.spreecommerce.org/developer/deployment/heroku.html) )
2. Install `spree_gladly` gem
3. Setup `signing_key` and provide to **Gladly** agent

## Testing

````
bundle exec rake test_app
bundle exec rake spec
````

For run specific test:
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/upsidelab/spree_gladly.

## Code of Conduct

Everyone interacting in the SpreeGladly project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/upsidelab/spree_gladly/blob/master/CODE_OF_CONDUCT.md).
