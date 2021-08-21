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

        def call
          Gladly::Api::Conversations::Create.new(payload: payload).call
        end

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
