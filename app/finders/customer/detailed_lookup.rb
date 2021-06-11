module Customer
  class DetailedLookup < Customer::BaseLookup
    def execute
      detailed_report
    end

    private

    def detailed_report
      customer
    end

    def customer_orders(customer_id:)
      return [] if customer_id.nil?

      order_scope.where(user_id: customer_id)
    end

    def guest_orders
      return [] if params.empty?

      order_scope.where(user_id: nil).where(email: params[:query][:emails])
    end

    def order_scope
      Spree::Order.unscoped.includes(:line_items, :payments, :shipments)
    end

    def customer
      @customer ||= Spree.user_class.includes(orders: [:line_items, :payments, :shipments]).find(params[:query][:externalCustomerId])
    end
  end
end
