# frozen_string_literal: true

module Customer
  class BasicLookup < Customer::BaseLookup
    def execute
      OpenStruct.new(
        guest_customers: guest_customers(registered_customers.pluck(:email)),
        registered_customers: registered_customers.uniq.sort
      )
    end

    private

    def guest_customers(excluded_emails)
      Customer::Guest::BasicFinder.new(emails: emails, options: { excluded_emails: excluded_emails }).execute
    end

    def registered_customers
      @registered_customers ||= Customer::Registered::BasicFinder.new(
        name: name,
        emails: emails,
        phones: phones
      ).execute
    end
  end
end
