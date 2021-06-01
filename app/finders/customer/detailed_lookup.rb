module Customer
  class DetailedLookup
    def initialize(params:)
      @params = params
    end

    def execute
      customers_id = customer_scope.map(&:id)

      return [] if customers_id.empty?

      detailed_report(customer_ids: customers_id)
    end

    private

    attr_reader :params

    def detailed_report(customer_ids:)
      Spree::Order.unscoped.includes(:line_items, :payments, :shipments).where(user_id: customer_ids)
    end

    def customer_scope
      Customer::BasicLookup.new(params: params).execute
    end
  end
end
