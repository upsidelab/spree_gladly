# frozen_string_literal: true

module Gladly
  module Events
    module Order
      class Refunded < Gladly::Events::Order::Base
        private

        def payload
          {
            customer: {
              emailAddress: customer_email
            },
            content: {
              type: 'CUSTOMER_ACTIVITY',
              title: "Order Adjusted #{order.number}",
              body: body_content,
              activityType: 'EMAIL',
              sourceName: 'Spree',
              link: {
                url: order_url,
                text: 'Link to Order - Spree'
              }
            }
          }
        end

        def body_content
          [
            "Amount Adjusted: #{Spree::Money.new(refund.amount).to_html}",
            "Adjustment Reason: #{refund.reason&.name}"
          ].join('<br>')
        end
      end
    end
  end
end
