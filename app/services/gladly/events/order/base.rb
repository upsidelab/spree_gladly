# frozen_string_literal: true

module Gladly
  module Events
    module Order
      class Base
        include Spree::Core::Engine.routes.url_helpers

        def initialize(order:, refund: nil)
          @order = order
          @refund = refund
        end

        # rubocop:disable Layout/LineLength
        def call
          Gladly::Api::Conversations::Create.new(payload: payload).call unless SpreeGladly::Config.turn_off_built_in_events
        end
        # rubocop:enable Layout/LineLength

        private

        attr_reader :order, :refund

        def customer_email
          order.email || order.user.email
        end

        def order_url
          edit_admin_order_url(id: order.number, host: Rails.application.routes.default_url_options[:host])
        end
      end
    end
  end
end
