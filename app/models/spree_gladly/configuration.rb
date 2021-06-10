module SpreeGladly
  class Configuration < ::Spree::Preferences::Configuration
    preference :signing_key, :string, default: nil
    preference :signing_threshold, :integer, default: nil
  end
end
