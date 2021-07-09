# frozen_string_literal: true

module Customer
  class DetailedLookup < Customer::BaseLookup
    def execute
      return registered_customer_result if registered_customer.present?
      return guest_customer_result if guest_customer.present?

      OpenStruct.new(customer: [], transactions: [])
    end

    private

    def guest_customer_result
      OpenStruct.new(customer: guest_customer, transactions: guest_orders, guest: true)
    end

    def registered_customer_result
      OpenStruct.new(customer: registered_customer, transactions: registered_orders, guest: false)
    end

    def guest_orders
      Spree::Order
        .includes(:line_items)
        .where("(#{order_table}.user_id IS NULL AND #{order_table}.email = ?)", guest_customer.email)
        .to_a
    end

    def registered_orders
      customer_orders = "(#{order_table}.user_id = ?)"
      guest_orders = "(#{order_table}.user_id IS NULL AND #{order_table}.email = ?)"

      Spree::Order
        .includes(:line_items)
        .where("#{customer_orders} OR #{guest_orders}", registered_customer.id, registered_customer.email)
        .to_a
    end

    def registered_customer
      @registered_customer ||= Spree.user_class.where('id = ? OR email = ?', spree_id.to_i, external_customer_id).take
    end

    def guest_customer
      @guest_customer ||= Spree::Order
                            .where(email: external_customer_id)
                            .order(created_at: :desc)
                            .first
    end

    def order_table
      Spree::Order.table_name
    end
  end
end
