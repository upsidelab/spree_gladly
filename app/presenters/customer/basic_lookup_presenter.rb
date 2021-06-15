module Customer
  class BasicLookupPresenter
    def initialize(resource:)
      @resource = resource
    end

    def to_h
      return {} if resource.empty?

      basic_payload
    end

    private

    attr_reader :resource

    def basic_payload
      resource.map do |user|
        {
          externalCustomerId: user.id.to_s,
          name: address(user)&.full_name.to_s,
          email: user.email,
          phone: address(user)&.phone.to_s
        }
      end
    end

    def address(user)
      @address ||= user.ship_address || user.bill_address
    end
  end
end
