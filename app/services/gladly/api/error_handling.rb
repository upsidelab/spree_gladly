# frozen_string_literal: true

module Gladly
  module Api
    module ErrorHandling
      # rubocop:disable Layout/LineLength
      def net_http_errors
        %w[Timeout::Error Errno::EINVAL Errno::ECONNRESET EOFError Net::HTTPBadResponse Net::HTTPHeaderSyntaxError Net::ProtocolError Net::HTTPUnauthorized]
      end
      # rubocop:enable Layout/LineLength

      def parse_error(error:)
        { errors: [{ code: error.code, detail: error.msg }] }
      end

      def not_implemented_error
        raise NotImplementedError
      end
    end
  end
end
