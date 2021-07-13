# frozen_string_literal: true

module Customer
  class DetailedLookupPresenter
    include Spree::Core::Engine.routes.url_helpers
    include Spree::BaseHelper

    def initialize(resource:)
      @resource = resource
    end

    def to_h
      return [] unless resource.customer.present?

      resource.guest ? guest_presenter : registered_presenter
    end

    private

    attr_reader :resource

    def registered_presenter
      Customer::Registered::DetailedPresenter.new(resource: resource).to_h
    end

    def guest_presenter
      Customer::Guest::DetailedPresenter.new(resource: resource).to_h
    end
  end
end
