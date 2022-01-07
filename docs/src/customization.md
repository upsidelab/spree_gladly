# Customization

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
