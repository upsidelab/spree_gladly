module Customer
  class BasicLookupPresenter
    def initialize(resource:)
      @resource = resource
    end

    def to_h
      return [] if resource.empty?

      basic_payload
    end

    private

    attr_reader :resource

    def basic_payload
      resource.map do |user|
        {
          externalCustomerId: user.id.to_s,
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
