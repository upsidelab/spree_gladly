# frozen_string_literal: true

module Customer
  class DetailedLookup < Customer::BaseLookup
    def execute
      OpenStruct.new(customer: customer, transactions: transactions)
    end

    private

    def transactions
      return [] unless customer.present?

      orders
    end

    def orders
      t = Spree::Order.table_name

      customer_orders = "(#{t}.user_id = ?)"
      guest_orders = "(#{t}.user_id IS NULL AND #{t}.email = ?)"

      Spree::Order
        .includes(:line_items)
        .where("#{customer_orders} OR #{guest_orders}", user_id, customer.email)
        .to_a
    end

    def customer
      @customer ||= Spree.user_class.find(user_id)
    rescue ActiveRecord::RecordNotFound
      @customer ||= []
    end

    def user_id
      external_customer_id.to_i
    end
  end
end
