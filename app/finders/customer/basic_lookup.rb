module Customer
  class BasicLookup < Customer::BaseLookup
    def execute
      customers = by_email
      customers += by_name
      customers += by_phone

      customers.uniq.sort
    end

    private

    def by_email
      return [] if emails.nil?

      scope.where(spree_users: { email: emails })
    end

    def by_name
      return [] if name.nil?

      # rubocop:disable Layout/LineLength
      scope.where("LOWER(#{Spree::Address.table_name}.firstname || ' ' || #{Spree::Address.table_name}.lastname) LIKE ?", "%#{query['name']&.downcase}%")
      # rubocop:enable Layout/LineLength
    end

    def by_phone
      return [] if phones.nil?

      scope.where(spree_addresses: { phone: phones })
    end

    def scope
      @scope ||= Spree.user_class.eager_load(:ship_address, :bill_address)
    end
  end
end
