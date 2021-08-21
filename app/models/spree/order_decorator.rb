# frozen_string_literal: true

module Spree
  module OrderDecorator
    def self.prepended(base)
      base.state_machine do
        after_transition to: :complete, do: :send_placed_order_event
      end
    end

    def send_placed_order_event
      Gladly::Events::Order::Placed.new(order: self).call
    end
  end
end
::Spree::Order.prepend(Spree::OrderDecorator)
