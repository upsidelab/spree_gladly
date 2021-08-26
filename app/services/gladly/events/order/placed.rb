# frozen_string_literal: true

module Gladly
  module Events
    module Order
      class Placed < Gladly::Events::Order::Base
        private

        def payload
          {
            customer: {
              emailAddress: customer_email
            },
            content: {
              type: 'CUSTOMER_ACTIVITY',
              title: "Order Placed #{order.number}",
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
            "Order Total: #{Spree::Money.new(order.total).to_html}",
            "Items Total: #{Spree::Money.new(order.line_items.map(&:total).sum).to_html}",
            "Adjustment Total: #{Spree::Money.new(order.adjustment_total).to_html}"
          ].join('<br>')
        end
      end
    end
  end
end
