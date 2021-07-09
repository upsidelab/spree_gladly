# frozen_string_literal: true

module Customer
  class BaseLookup
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

    def normalize_param(param:)
      return [] if param.nil?
      return param if param.is_a?(Array)

      param.split(',').map(&:strip)
    end

    def concat(*args)
      if adapter =~ /mysql/i
        "CONCAT(#{args.join(',')})"
      else
        args.join('||')
      end
    end

    def adapter
      if ActiveRecord::Base.respond_to?(:connection_db_config)
        ActiveRecord::Base.connection_db_config.configuration_hash[:adapter]
      else
        ActiveRecord::Base.connection_config[:adapter]
      end
    end
  end
end
