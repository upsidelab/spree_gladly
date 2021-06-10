module Customer
  class BaseLookup
    def initialize(params:)
      @params = params
      @query = params.include?(:query) ? params.fetch(:query) : {}

      @emails = normalize_param(param: query[:emails])
      @phones = normalize_param(param: query[:phones])
      @name = query[:name]
    end

    private

    attr_reader :params, :query, :emails, :phones, :name

    def normalize_param(param:)
      return [] if param.nil?
      return param if param.is_a?(Array)

      param.split(',').map(&:strip)
    end
  end
end
