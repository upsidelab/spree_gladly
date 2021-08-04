# SpreeGladly
[comment]: <> (add Travis status build badge when repo became public)

## Overview
This exetension allows you to connect your  [Spree](https://github.com/spree/spree) store with [Gladly](https://www.gladly.com/) service. It allows Gladly agents to see basic information about Spree customers and their orders.

It adheres to the specification of a Gladly Lookup adapter as described [here](https://developer.gladly.com/tutorials/lookup).

Supported Spree versions: `3.0`, `3.1`, `3.7`, `4.0`, `4.1`, `4.2`

**Table of contents:**
- [SpreeGladly](#spreegladly)
  - [Overview](#overview)
  - [Installation](#installation)
  - [Configuration](#configuration)
    - [Spree Store side:](#spree-store-side)
    - [Gladly Service side:](#gladly-service-side)
  - [Customization](#customization)
  - [Usage](#usage)
    - [Basic Lookup](#basic-lookup)
      - [Manual Search Request](#manual-search-request)
      - [Automatic Search Request](#automatic-search-request)
      - [Basic Lookup Response](#basic-lookup-response)
    - [Detailed Lookup](#detailed-lookup)
    - [How does the search work? What do the fields mean?](#how-does-the-search-work-what-do-the-fields-mean)
      - [Basic search](#basic-search)
      - [Detailed search](#detailed-search)
  - [Setup sandbox environment](#setup-sandbox-environment)
  - [Testing](#testing)
  - [Contributing](#contributing)
  - [Code of Conduct](#code-of-conduct)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spree_gladly'
```

And then execute:

    $ bundle install

Next, you should run the installer:

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
  config.order_limit = nil
  config.order_includes = [:line_items]
  config.order_sorting = { created_at: :desc }
  config.order_states = ['complete']
  
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
- **order_limit:** *you can set limit returned orders number in `detailed lookup` response, if `nil` than no limits `default: nil`*  
- **order_includes:** *you can set what relation should be included in query, `default: :line_items`. Also that this gets passed into .include() when fetching detailed lookup - if you want to display data from order's relationships, you may want to optimize the query*  
- **order_sorting:** *you can set how returned orders should be sorted `default: { created_at: :desc }`
- **order_states:** *you can set order `state` which should be returned in response `default: ['complete']`. This defines states of `orders` that will be returned to Gladly (and that by default it will exclude `Spree::Orders` in `cart|address|delivery|payment` states*

You can also set `signing_key` and `signing_threshold` via the admin dashboard in your Spree instance. To do that, open `Gladly Settings` in the `Configurations` section.

<img width="1436" alt="gladly_settings_admin_dashboard" src="https://user-images.githubusercontent.com/1455599/123083627-83c99400-d420-11eb-87ca-c1c5e20583d9.png">

### !!! Important !!!

Detailed lookups find customer's orders based on customer's profile, but will also include guest orders made with the same email address.
By default, Spree doesn't index the `email` field of `Spree::Orders` table. To ensure smooth operation of the lookup endpoint, add the following migration to your application.
```ruby
class AddEmailIndexToSpreeOrders < ActiveRecord::Migration

  def change
    add_index :spree_orders, :email
  end
end
```
***Note: please adjust migration to yours Rails version***


### Gladly Service side:

Provide to your agent:
- lookup endpoint (  `https://example-spree-store.com/api/v1/customers/lookup` ), where `https://example-spree-store.com` is **your** Spree store URL.
- signing_key 

## Customization

Within `spree_gladly` gem we distinguish response for `guest` and `registerd` customer. For customize those, i.e [detailed lookup response](#detailed-lookup), to do that you have do following steps:

1. replace `Customer::DetailedLookupPresenter` in `config/initializers/spree_gladly.rb` initializer file with your own.
2. override methods `registerd_presenter` ( [default presenter](https://github.com/upsidelab/spree_gladly/blob/master/app/presenters/customer/registered/detailed_presenter.rb) ) or `guest_presenter` ( [default presenter](https://github.com/upsidelab/spree_gladly/blob/master/app/presenters/customer/guest/detailed_presenter.rb) ) with your own. 

Please consider below example:

```ruby
class GladlyCustomersPresenter
  include Spree::Core::Engine.routes.url_helpers # this is important if you want to use Spree routes

  def initialize(resource:)
    @resource = resource
  end

  def to_h
    return [] unless resource.customer.present?

    resource.guest ? guest_presenter : registered_presenter
  end

  private

  attr_reader :resource

  def registered_presenter
    YourOwn::DetailedPresenter.new(resource: resource).to_h
  end

  def guest_presenter
    Customer::Guest::DetailedPresenter.new(resource: resource).to_h
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

The below description will assume that the reader has familiarized themselves with [Gladly Lookup Adapter tutorial](https://developer.gladly.com/tutorials/lookup).

### Basic Lookup

The aim of basic search is to allow the agent to find potential customers that match the information that they have at hand, e.g. email, phone number, name.
As mentioned in the [Gladly tutorial](https://developer.gladly.com/tutorials/lookup) the initial search can be triggered automatically or by agent and because of that the Spree adapter accepts two different formats of requests.

#### Manual Search Request
OOTB the extension allows searching by email, phone number and name of the customer. Additional fields can be added.

```json
{
  "lookupLevel":"BASIC",
  "uniqueMatchRequired":false,
  "query":{
    "emails":"customer@example.com",
    "phones":"666-666-666",
    "name": "Elka Melka",
  }
}
```

#### Automatic Search Request
The request is automatically populated with data available in customer's profile. OOTB the extension searches for customers based on the name, emails and phone numbers (ignoring the rest of the fields).

```json
{
  "lookupLevel":"BASIC",
  "uniqueMatchRequired":false,
  "query":
    {
      "emails":["customer@example.com", "another@email.com"],
      "phones": ["666-666-666", "123-435-235"],
      "name": "Elka Melka",
      "lifetimeValue": "$500"
    }
}
```

#### Basic Lookup Response

By default the fields listed below are returned. Fields can be hidden via Gladly UI or the integration
can be extended to return more/different fields. The format of the response has to match the [Gladly Customer schema](https://developer.gladly.com/rest/#operation/createCustomer)
Note: we use the email address as the `externalCustomerId` and not the id used by Spree.

```json
{
  "results":[
    {
      "externalCustomerId": "customer@example.com",
      "customAttributes": {
        "spreeId": 1
      },
      "name": "James Bond",
      "emails": [{"original": "customer@example.com"}],
      "phones": [{"original": "666-666-666"}],
      "address": "22 Apple Lane, 9999 San Francisco"
    }
  ]
}
```

### Detailed Lookup

Detailed lookup is used to update the linked customer with detailed data. This means that detailed lookup expects only one result returned. Gladly will send in the request all the customer's information except transactions. However, only the `externalCustomerId` is used to find the correct customer in Spree.

**request payload:**

```json
{
  "lookupLevel":"DETAILED",
  "uniqueMatchRequired":true,
  "query":{
    "name": "Some name",
    "totalOrderCount": "4",
    "emails":[ "customer@example.com", "another@email.com"],
    "phones":[
      "666-666-666"
    ],
    "externalCustomerId":"customer@example.com",
    "customAttributes": {
      "spreeId": 1
    }
  }
}
```

**response payload:**
The following payload shows all the fields that are returned from Spree. You can ask your Gladly representative to amend which fields are visible in the order card.

```json
{
  "results":[
    {
      "externalCustomerId": "customer@example.com",
      "name":"James Bond",
      "address":"Baker Street 007 London, AK 00021 United Kingdom",
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
        "spreeId": "4",
        "lifetimeValue":"$142.97",
        "totalOrderCount":"2",
        "guestOrderCount": "0",
        "memberSince" : "May 17, 2021 10:18 AM UTC",
        "customerLink": "https://example-spree-store.com/admin/users/4/edit"
      },
      "transactions":[
        {
          "type":"ORDER",
          "orderStatus":"complete",
          "orderNumber":"R185194841",
          "orderLink":"https://example-spree-store.com/admin/orders/R185194841/edit",
          "note":"",
          "orderTotal":"$83.99",
          "createdAt":"2021-06-21T10:29:43.881Z",
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
          ]
        },
        {
          "type":"ORDER",
          "orderStatus":"complete",
          "orderNumber":"R461455233",
          "orderLink":"https://example-spree-store.com/admin/orders/R461455233/edit",
          "note":"Some note about the order",
          "orderTotal":"$58.98",
          "createdAt":"2021-06-21T10:34:10.262Z",
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
          ]
        }
      ]
    }
  ]
}
```

### How does the search work? What do the fields mean?

It's worth noting that in Spree customers are able to create orders without being logged in. It is important to be able to link such customers with their Gladly profiles to be able to help them.
This slightly complicates the search and makes it worth an explanation. Since we want to be able to identify both registered customers and customers with only guest orders, we are using the email address instead of the `Spree::Account.id` as `externalCustomerId` in Gladly (the unique identifier of a customer in an external system).

Note detailes on the exact format of the jsons was shown in previous section. The below tables are for information of the meaning of the fields.

#### Basic search

As mentioned in [Basic Lookup](#basic-lookup) searching by name, emails and phone numbers is possible.
To simplify the search logic and improve performance searching by name and phone number will only search customers with Spree profiles.
Searching by email searches both registered customers and guest orders. It happens in two phases (for each customer's email separately):

1. Attempt to find any customers with a Spree profile with the given email. If found, search will return that customer.
2. If no customer is found the search will attempt to find all orders associated with the given email. If multiple orders are found it will return the details of the latest (`completed_at`) order.

Below table explains the returned fields.

**For registered customers:**

| Gladly customer field    | Spree field                                                                            |
| ------------------------ | -------------------------------------------------------------------------------------- |
| name                     | Spree::User.bill_address.full_name                            |
| externalCustomerId       | Spree::User.email                                                                      |
| emails                   | Spree::User.email                                                           |
|                          |
| customAttributes.spreeId | Spree::User.id                                                                         |
| phones                   | Spree::User.bill_address.phone                                |
| address                  | Spree::User.bill_address (address1, address2, city,  zipcode) |

**For guest customers**

In the below table Spree::Order means the latest (`Spree::Order.completed_at`) order that matched the email from the search.

| Gladly field       | Spree                                                            |
| ------------------ | ---------------------------------------------------------------- |
| name               | Spree::Order.bill_address.full_name                           |
| externalCustomerId | Spree::Order.email                                               |
| emails             | Spree::Order.email                                               |
| phones             | Spree:Order.bill_address.phone                                |
| address            | Spree::Order.bill_address.(address1, address2, city, zipcode) |

#### Detailed search

Detailed search assumes that we have found the right customer and we know their unique identifier. In Gladly this is the `externalCustomerId` and in Spree, it's equivalent to the email address.

The below tables list the fields returned from Spree.

**For registered customers:**

| Gladly field                     | Spree field                                                                            |
| -------------------------------- | -------------------------------------------------------------------------------------- |
| name                             | Spree::User.bill_address.full_name                            |
| externalCustomerId               | Spree::User.email                                                                      |
| emails                           | [ Spree::User.email ]                                                       |
| phones                           | [ Spree::User.bill_address.phone ]                            |
| address                          | Spree::User.bill_address.(address1 , address2, city, zipcode) |
| customAttributes.spreeId         | Spree::User.id                                                                         |
| customAttributes.totalOrderCount | total of Spree::Order(s) that match the `externalCustomerId`                           |
| customAttributes.guestOrderCount | customAttributes.totalOrderCount - Spree::Account.attributes.completed_orders          |
| customAttributes.memberSince     | Spree::User.created_at                                                                                     |
| customAttributes.customerLink    | customer_profile_url(Spree::User)                                                                                      |
| customAttributes.lifetimeValue   | sum `total` field of Spree::Order(s) that match the `externalCustomerId`                                                                                    |
| transactions                     | details of all Spree::Orders that match the `externalCustomerId`                       |

**For guest customers**

| Gladly field                     | Spree field                                                      |
| -------------------------------- | ---------------------------------------------------------------- |
| name                             | -                                                                |
| externalCustomerId               | externalCustomerId (return the same value)                       |
| emails                           | -                                                                |
| phones                           | -                                                                |
| address                          | -                                                                |
| customAttributes.spreeId         | -                                                                |
| customAttributes.totalOrderCount | total of Spree::Orders that match the `externalCustomerId`       |
| customAttributes.guestOrderCount | customAttributes.totalOrderCount                                 |
| customAttributes.memberSince     | -                                                                |
| customAttributes.customerLink    | -                                                                |
| customAttributes.lifetimeValue   | sum `total` field of Spree::Order(s) that match the `externalCustomerId`                                                                 |
| transactions                     | details of all Spree::Orders that match the `externalCustomerId` |

## Setup sandbox environment

1. Deploy Spree store on hosting provider ( [heroku example](https://guides.spreecommerce.org/developer/deployment/heroku.html) )
2. Install `spree_gladly` gem
3. Setup `signing_key` and provide to **Gladly** agent

## Testing

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/upsidelab/spree_gladly.

## Code of Conduct

Everyone interacting in the SpreeGladly project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/upsidelab/spree_gladly/blob/master/CODE_OF_CONDUCT.md).
