SpreeGladly.setup do |config|
  # The key used to validate the Gladly lookup request signature.
  # We recommend using a secure random string of length over 32.
  # Setting this value to `nil` disables request signature validation.
  # Default is `nil`.
  # config.signing_key = '<%= SecureRandom.base64(32) %>'

  # The request's timestamp is validated against `signing_threshold` to prevent replay attacks.
  # Setting this value to `nil` disables the threshold validation.
  # Default is `nil`.
  # config.signing_threshold = 5.minutes
end
