# Spree Store

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
- **order_includes:** *you can set what relation should be included in query, `default: :line_items`. This gets passed into .include() when fetching detailed lookup - if you want to display data from order's relationships, you may want to optimize the query*
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
