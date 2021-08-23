module SpreeGladly
  class Configuration < ::Spree::Preferences::Configuration
    preference :signing_key, :string, default: ''
    preference :signing_threshold, :integer, default: 0

    attr_accessor :basic_lookup_presenter,
                  :detailed_lookup_presenter,
                  :order_limit,
                  :order_includes,
                  :order_sorting,
                  :order_states,
                  :gladly_api_username,
                  :gladly_api_key,
                  :gladly_api_base_url,
                  :turn_off_built_in_events

    @basic_lookup_presenter = nil

    @detailed_lookup_presenter = nil

    @order_limit = nil

    @order_includes = nil

    @order_sorting = nil

    @order_states = nil

    @gladly_api_username = nil

    @gladly_api_key = nil

    @gladly_api_base_url = nil

    @turn_off_built_in_events = nil
  end
end
