module SpreeGladly
  class Configuration < ::Spree::Preferences::Configuration
    preference :signing_key, :string, default: ''
    preference :signing_threshold, :integer, default: 0
  end
end
