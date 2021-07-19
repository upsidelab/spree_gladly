module Customer
  class AddressPresenter
    def initialize(address)
      @address = address
    end

    def to_s
      return nil if address.nil?

      components = [
        address.address1,
        address.address2,
        address.city,
        address.state_text,
        address.zipcode,
        address.country.to_s
      ]

      components.reject(&:blank?)
                .join(', ')
    end

    private

    attr_reader :address
  end
end
