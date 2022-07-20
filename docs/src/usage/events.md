# Events

Within gem we introduce [Conversations (Create Item)](https://developer.gladly.com/rest/#operation/createItem) using API client. 
We implemented two events against `Spree::Order` model:
 - `Placed` - it's fired up after Order is completed by customer ( `Gladly::Events::Order::Placed`)
 - `Refundned` - it's fired up after Order items are returned to customer  ( `Gladly::Events::Order::Refunded`)
 
More about [Conversations](https://developer.gladly.com/rest/#tag/Conversations)

#### Configuration

**Important !!!**

**Without bellow settings events will won't work. You will get those from yours Gladly dashboard**

```ruby
config.gladly_api_username = 'api_username@example.com'
config.gladly_api_key = 'api_key'
config.gladly_api_base_url = 'https://dev-example.gladly.qa'
config.turn_off_built_in_events = false
```

In case when you need write your own events class you can switch off built-in events by setting `turn_off_built_in_events` as `true`
