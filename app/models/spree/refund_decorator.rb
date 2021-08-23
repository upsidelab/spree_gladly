# frozen_string_literal: true

module Spree
  module RefundDecorator
    def perform!
      super
      Gladly::Events::Order::Refunded.new(order: payment.order, refund: self).call
    end
  end
end
::Spree::Refund.prepend(Spree::RefundDecorator)
