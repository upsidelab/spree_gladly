# frozen_string_literal: true

module Customer
  class DetailedLookup < Customer::BaseLookup
    def execute
      guest_customer? ? guest_customer : registered_customer
    end

    private

    def guest_customer
      Customer::Guest::DetailedFinder.new(email: external_customer_id).execute
    end

    def registered_customer
      Customer::Registered::DetailedFinder.new(customer: customer).execute
    end
  end
end
