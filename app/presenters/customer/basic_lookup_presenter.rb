# frozen_string_literal: true

module Customer
  class BasicLookupPresenter
    def initialize(resource:)
      @resource = resource
      @registered_customers = resource.registered_customers
      @guest_customers = resource.guest_customers
    end

    def to_h
      return [] if guest_customers.empty? && registered_customers.empty?

      registered_presenter.concat(guest_presenter)
    end

    private

    attr_reader :resource, :registered_customers, :guest_customers

    def registered_presenter
      Customer::Registered::BasicPresenter.new(resource: registered_customers).to_h
    end

    def guest_presenter
      Customer::Guest::BasicPresenter.new(resource: guest_customers).to_h
    end
  end
end
