# frozen_string_literal: true

module Auth
  class AuthorizationHeader
    AUTHORIZATION_HEADER_FORMAT =
      /\ASigningAlgorithm=([[-a-z0-9]]+), SignedHeaders=([[-a-z0-9;]]+), Signature=([[a-f0-9]]+)\Z/.freeze

    attr_reader :signing_algorithm_name, :signing_algorithm, :signed_headers, :signature

    def initialize(header)
      match = AUTHORIZATION_HEADER_FORMAT.match(header)
      raise HeaderParseError, 'Unsupported Gladly-Authorization header format' if match.nil?

      @signing_algorithm_name = match[1]
      @signing_algorithm = parse_signing_algorithm!(@signing_algorithm_name.gsub('hmac-', ''))
      @signed_headers = parse_headers!(match[2])
      @signature = match[3]
    end

    private

    def parse_signing_algorithm!(value)
      OpenSSL::Digest.new(value)
    rescue RuntimeError
      raise HeaderParseError, "Unsupported signing algorithm (#{value})"
    end

    def parse_headers!(value)
      headers = value.split(';')
      raise HeaderParseError, 'Signed headers should be sorted' unless headers == headers.sort

      headers
    end
  end
end
