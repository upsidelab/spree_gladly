module Customer
  class BaseLookup
    def initialize(params:)
      @params = params
      @query = params.include?(:query) ? params.fetch(:query) : {}

      @emails = normalize_param(param: query[:emails])
      @phones = normalize_param(param: query[:phones])
      @name = query[:name]
      @external_customer_id = query[:externalCustomerId]
    end

    private

    attr_reader :params, :query, :emails, :phones, :name, :external_customer_id

    def normalize_param(param:)
      return [] if param.nil?
      return param if param.is_a?(Array)

      param.split(',').map(&:strip)
    end
  end
end
