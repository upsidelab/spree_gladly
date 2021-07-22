# frozen_string_literal: true

module Customer
  module Guest
    class DetailedFinder
      def initialize(email:)
        @email = email
      end

      def execute
        OpenStruct.new(customer: customer, transactions: transactions, guest: true)
      end

      private

      attr_reader :email

      def customer
        transactions.first || []
      end

      def transactions
        @transactions ||= find_transactions
      end

      def find_transactions
        scope = Spree::Order
                .includes(SpreeGladly::Config.order_includes)
                .order(SpreeGladly::Config.order_sorting)
                .where("(#{order_table}.user_id IS NULL AND #{order_table}.email = ?)", email)


        scope = scope.limit(SpreeGladly::Config.order_limit) if SpreeGladly::Config.order_limit
        scope.to_a
      end

      def order_table
        Spree::Order.table_name
      end
    end
  end
end
