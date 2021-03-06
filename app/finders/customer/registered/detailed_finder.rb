# frozen_string_literal: true

module Customer
  module Registered
    class DetailedFinder
      def initialize(customer:)
        @customer = customer
      end

      def execute
        return empty_result if customer.nil?

        OpenStruct.new(customer: customer, transactions: transactions, guest: false)
      end

      private

      attr_reader :customer

      def transactions
        customer_orders = "(#{order_table}.user_id = ?)"
        guest_orders = "(#{order_table}.user_id IS NULL AND #{order_table}.email = ?)"

        scope = Spree::Order
                .includes(SpreeGladly::Config.order_includes)
                .where(state: SpreeGladly::Config.order_states)
                .order(SpreeGladly::Config.order_sorting)
                .where("#{customer_orders} OR #{guest_orders}", customer.id, customer.email)

        scope = scope.limit(SpreeGladly::Config.order_limit) if SpreeGladly::Config.order_limit
        scope.to_a
      end

      def empty_result
        OpenStruct.new(customer: [], transactions: [], guest: false)
      end

      def order_table
        Spree::Order.table_name
      end
    end
  end
end
