module SpreeGladly
  class Configuration < ::Spree::Preferences::Configuration
    preference :signing_key, :string, default: ''
    preference :signing_threshold, :integer, default: 0

    attr_accessor :basic_lookup_presenter,
                  :detailed_lookup_presenter,
                  :order_limit,
                  :order_includes,
                  :order_sorting,
                  :order_states

    @basic_lookup_presenter = nil

    @detailed_lookup_presenter = nil

    @order_limit = nil

    @order_includes = nil

    @order_sorting = nil

    @order_states = nil
  end
end
