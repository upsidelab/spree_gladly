# frozen_string_literal: true

module Auth
  class SignatureValidator
    def initialize(key = SpreeGladly.signing_key, threshold = SpreeGladly.signing_threshold)
      @key = key
      @threshold = threshold
    end

    def validate(request)
      raise Auth::MissingKeyError, 'Signing Key is not set' unless @key.present?

      authorization_header = authorization_header(request)
      time_header = time_header(request)

      validate_time!(time_header)

      validate_signature!(request, authorization_header, time_header)
    end

    private

    def validate_time!(time_header)
      return true unless @threshold

      return true if time_header.time + @threshold >= Time.now.utc

      raise Auth::InvalidSignatureError, 'Signature is too old'
    end

    def validate_signature!(request, authorization_header, time_header)
      string_to_be_signed = string_to_be_signed(authorization_header, time_header, request)
      salted_key = OpenSSL::HMAC.digest(authorization_header.signing_algorithm, @key, time_header.date)
      signature = OpenSSL::HMAC.hexdigest(authorization_header.signing_algorithm, salted_key, string_to_be_signed)

      return true if ActiveSupport::SecurityUtils.secure_compare(signature, authorization_header.signature)

      raise Auth::InvalidSignatureError, 'Signature is incorrect'
    end

    def string_to_be_signed(authorization_header, time_header, request)
      [
        authorization_header.signing_algorithm_name,
        time_header.timestamp,
        normalized_request_hash(authorization_header, request)
      ].join("\n")
    end

    def authorization_header(request)
      AuthorizationHeader.new(fetch_header(request, 'Gladly-Authorization'))
    end

    def time_header(request)
      TimeHeader.new(fetch_header(request, 'Gladly-Time'))
    end

    def fetch_header(request, header)
      request.headers.fetch(header)
    rescue KeyError
      raise HeaderParseError, "#{header} header is missing"
    end

    def normalized_request_hash(authorization_header, request)
      normalized_request = RequestNormalizer.new(authorization_header.signed_headers).normalize(request)
      OpenSSL::Digest.new('sha256').hexdigest(normalized_request)
    end
  end
end
