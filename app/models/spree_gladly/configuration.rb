module SpreeGladly
  class Configuration < ::Spree::Preferences::Configuration
    preference :signing_key, :string, default: ''
    preference :signing_threshold, :integer, default: 0

    attr_accessor :basic_lookup_presenter, :detailed_lookup_presenter

    @basic_lookup_presenter = nil

    @detailed_lookup_presenter = nil
  end
end
