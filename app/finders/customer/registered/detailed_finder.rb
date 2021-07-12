# frozen_string_literal: true

module Customer
  module Registered
    class DetailedFinder
      def initialize(customer:)
        @customer = customer
      end

      def execute
        OpenStruct.new(customer: customer, transactions: transactions, guest: false)
      end

      private

      attr_reader :customer

      def transactions
        customer_orders = "(#{order_table}.user_id = ?)"
        guest_orders = "(#{order_table}.user_id IS NULL AND #{order_table}.email = ?)"

        Spree::Order
          .includes(:line_items)
          .where("#{customer_orders} OR #{guest_orders}", customer.id, customer.email)
          .to_a
      end

      def order_table
        Spree::Order.table_name
      end
    end
  end
end
