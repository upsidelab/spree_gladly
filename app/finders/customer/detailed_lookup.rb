module Customer
  class DetailedLookup < Customer::Base
    def execute
      customers_id = customer_scope.map(&:id)

      detailed_report(customer_ids: customers_id)
    end

    private

    def detailed_report(customer_ids:)
      customer_orders(customer_ids: customer_ids) + guest_orders
    end

    def customer_orders(customer_ids:)
      return [] if customer_ids.empty?

      order_scope.where(user_id: customer_ids)
    end

    def guest_orders
      return [] if params.empty?

      order_scope.where(user_id: nil).where(email: params[:query][:emails])
    end

    def order_scope
      Spree::Order.unscoped.includes(:line_items, :payments, :shipments)
    end

    def customer_scope
      Customer::BasicLookup.new(params: params).execute
    end
  end
end
