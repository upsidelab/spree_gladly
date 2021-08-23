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

  # API CONFIG
  config.gladly_api_username = ''
  config.gladly_api_key = ''
  config.gladly_api_base_url = ''
end
