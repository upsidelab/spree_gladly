# frozen_string_literal: true

module Auth
  class RequestNormalizer
    def initialize(signed_headers)
      @signed_headers = signed_headers
    end

    def normalize(request)
      <<~NORMALIZED.chomp
        #{request.method}
        #{request.original_fullpath}

        #{normalize_headers(request.headers)}

        #{normalize_signed_headers}
        #{normalize_body(request.body.read)}
      NORMALIZED
    end

    private

    def normalize_headers(headers)
      @signed_headers
        .map { |header| "#{header}:#{headers.fetch(header, '')}" }
        .join("\n")
    end

    def normalize_signed_headers
      @signed_headers.join(';')
    end

    def normalize_body(body)
      OpenSSL::Digest.new('sha256').hexdigest(body)
    end
  end
end
