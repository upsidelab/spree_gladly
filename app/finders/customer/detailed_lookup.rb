module Customer
  class DetailedLookup < Customer::BaseLookup
    def execute
      OpenStruct.new(customer: customer, transactions: transactions)
    end

    private

    def transactions
      return [] unless customer.present?

      customer.orders + guest_orders
    end

    def guest_orders
      Spree::Order.includes(:line_items).where(user_id: nil).where(email: customer.email)
    end

    def customer
      @customer ||= Spree.user_class.includes(orders: %i[line_items]).find(external_customer_id.to_i)
    rescue ActiveRecord::RecordNotFound
      @customer ||= []
    end
  end
end
