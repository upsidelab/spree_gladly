module Customer
  class BasicLookupPresenter
    def initialize(resource:)
      @resource = resource
      @registered_customers = resource.registered_customers
      @guest_customers = resource.guest_customers
    end

    def to_h
      return [] if guest_customers.empty? && registered_customers.empty?

      # todo split presenteres for: guest and registered
      guests = Customer::GuestPresenter.new(resource: guest_customers).to_h
      registered = basic_payload

      registered.concat(guests)
    end

    private

    attr_reader :resource, :registered_customers, :guest_customers

    def basic_payload
      return [] if registered_customers.empty?

      registered_customers.map do |user|
        {
          externalCustomerId: user.email,
          address: address(user).to_s&.gsub('<br/>', ' '),
          name: address(user)&.full_name.to_s,
          emails: customer_emails(user),
          phones: customer_phones(user)
        }
      end
    end


    def customer_emails(user)
      [
        {
          original: user.email
        }
      ]
    end

    def customer_phones(user)
      [
        {
          original: address(user)&.phone.to_s
        }
      ]
    end

    def address(user)
      user.ship_address
    end
  end
end
