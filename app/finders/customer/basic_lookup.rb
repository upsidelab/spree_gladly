module Customer
  class BasicLookup
    def initialize(params:)
      @params = params
      @query = params.include?(:query) ? params.fetch(:query) : {}

      @emails = query[:emails]
      @phones = query[:phones]
      @name = query[:name]
    end

    def execute
      customers = by_email
      customers += by_name
      customers += by_phone

      customers.uniq.sort
    end

    private

    attr_reader :query, :emails, :phones, :name

    def by_email
      return [] if emails.nil?

      formatted_emails = emails.split(',').map(&:strip)
      scope.where(spree_users: { email: formatted_emails })
    end

    def by_name
      return [] if name.nil?

      # rubocop:disable Layout/LineLength
      scope.where("#{Spree::Address.table_name}.firstname || ' ' || #{Spree::Address.table_name}.lastname LIKE ?", "%#{query['name']}%")
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
