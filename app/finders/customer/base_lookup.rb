# frozen_string_literal: true

module Customer
  class BaseLookup
    include Customer::DatabaseAdapter

    def initialize(params:)
      @params = params
      @query = params.include?(:query) ? params.fetch(:query) : {}

      @emails = normalize_param(param: query[:emails])
      @phones = normalize_param(param: query[:phones])
      @name = query[:name]
      @external_customer_id = query[:externalCustomerId]
      @spree_id = query[:spreeId]
    end

    private

    attr_reader :params, :query, :emails, :phones, :name, :external_customer_id, :spree_id

    def customer
      @customer ||= Spree.user_class.where('id = ? OR email = ?', spree_id.to_i, external_customer_id).take
    end

    def guest_customer?
      !customer.present?
    end

    def normalize_param(param:)
      return [] if param.nil?
      return param if param.is_a?(Array)

      param.split(',').map(&:strip)
    end
  end
end
