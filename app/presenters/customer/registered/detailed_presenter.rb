# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module Customer
  module Registered
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
            name: address&.full_name,
            address: address.to_s&.gsub('<br/>', ' '),
            emails: emails,
            phones: phones,
            customAttributes: custom_attributes,
            transactions: transactions
          }
        ]
      end

      def custom_attributes
        {
          spreeId: resource.customer.id,
          lifetimeValue: lifetime_value,
          totalOrderCount: resource.transactions.size.to_s,
          guestOrderCount: calculate_guest_transactions.to_s,
          memberSince: pretty_time(resource.customer.created_at).to_s,
          customerLink: customer_profile_url(resource.customer)
        }
      end

      def transactions
        resource.transactions.map do |transaction|
          {
            type: 'ORDER',
            orderStatus: transaction.state,
            orderNumber: transaction.number,
            guest: transaction_type(transaction),
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

      def calculate_guest_transactions
        resource.transactions.select { |item| item.user_id.nil? }.size
      end

      def transaction_type(order)
        order.user_id.nil? ? 'yes' : 'no'
      end

      def customer_profile_url(customer)
        edit_admin_user_url(id: customer.id, host: Rails.application.routes.default_url_options[:host])
      end

      def order_url(transaction)
        edit_admin_order_url(id: transaction.number, host: Rails.application.routes.default_url_options[:host])
      end

      def lifetime_value
        return '0' if resource.transactions.empty?

        Spree::Money.new(resource.transactions.sum(&:total)).to_html
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
        @address ||= resource.customer.bill_address
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
