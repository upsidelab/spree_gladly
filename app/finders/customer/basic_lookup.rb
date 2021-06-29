# frozen_string_literal: true

module Customer
  class BasicLookup < Customer::BaseLookup
    def execute
      customers = registered_customers || guest_customers

      customers.uniq.sort
    end

    private

    def registered_customers
      conditions = search_conditions
      return empty_scope unless conditions.present?

      template = conditions.map(&:first).join(' OR ')
      args = conditions.map(&:last)

      scope.where(template, *args)
    end

    def guest_customers
      Spree::Order
        .where(user_id: nil)
        .where(email: emails) # should we search by each provided email ?
        .order(created_at: :desc)
        &.first
    end

    def search_conditions
      [by_email, by_name, by_phone].compact
    end

    def by_email
      return nil unless emails.present?

      where = "#{Spree.user_class.table_name}.email IN (?)"
      [where, emails]
    end

    def by_name
      return nil unless name.present?

      sql_name = concat("#{Spree::Address.table_name}.firstname", "' '", "#{Spree::Address.table_name}.lastname")
      where = "(LOWER(#{sql_name}) LIKE ?)"
      args = "%#{name.downcase}%"
      [where, args]
    end

    def by_phone
      return nil unless phones.present?

      where = "#{Spree::Address.table_name}.phone IN (?)"
      [where, phones]
    end

    def empty_scope
      Spree.user_class.none
    end

    def scope
      Spree.user_class.eager_load(:ship_address, :bill_address)
    end
  end
end
