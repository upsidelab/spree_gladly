# frozen_string_literal: true

module Customer
  module Guest
    class DetailedPresenter
      include Spree::Core::Engine.routes.url_helpers
      include Spree::BaseHelper

      def initialize(resource:)
        @resource = resource
      end

      def to_h
        return [] unless resource.customer.present?

        detailed_payload
      end

      private

      attr_reader :resource

      def detailed_payload
        [
          {
            externalCustomerId: resource.customer.email,
            customAttributes: custom_attributes,
            transactions: transactions
          }
        ]
      end

      def custom_attributes
        {
          totalOrderCount: transactions_size,
          guestOrderCount: transactions_size
        }
      end

      def transactions
        resource.transactions.map do |transaction|
          {
            type: 'ORDER',
            orderStatus: transaction.state,
            orderNumber: transaction.number,
            guest: 'yes',
            products: transaction_products(transaction: transaction),
            orderLink: order_url(transaction),
            note: transaction&.special_instructions.to_s,
            orderTotal: Spree::Money.new(transaction.total).to_html,
            createdAt: transaction.created_at
          }
        end
      end

      def transaction_products(transaction:)
        transaction.line_items.map do |item|
          {
            name: item.variant.name,
            status: item_status(item: item),
            sku: item.variant.sku,
            quantity: item.quantity.to_s,
            total: Spree::Money.new(item.total).to_html,
            unitPrice: Spree::Money.new(item.price).to_html,
            imageUrl: item_image_url(item: item)
          }
        end
      end

      def transactions_size
        @transactions_size ||= resource.transactions.size.to_s
      end

      def order_url(transaction)
        edit_admin_order_url(id: transaction.number, host: Rails.application.routes.default_url_options[:host])
      end

      def item_image_url(item:)
        return '' if item.product.images.empty?

        item.product.images.first&.attachment&.url
      end

      def item_status(item:)
        item.sufficient_stock? ? 'fulfilled' : 'cancelled'
      end

      def emails
        [
          {
            original: resource.customer.email
          }
        ]
      end

      def phones
        [
          {
            original: address&.phone
          }
        ]
      end

      def address
        @address ||= resource.customer.ship_address
      end
    end
  end
end
