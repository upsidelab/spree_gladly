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
        transactions.first
      end

      def transactions
        @transactions ||= Spree::Order
                            .includes(:line_items)
                            .where("(#{order_table}.user_id IS NULL AND #{order_table}.email = ?)", email)
                            .to_a
      end

      def order_table
        Spree::Order.table_name
      end
    end
  end
end
