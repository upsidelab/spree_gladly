# frozen_string_literal: true

require 'net/http'

module Gladly
  module Api
    class Client
      include Gladly::Api::ErrorHandling

      def initialize(payload: {})
        @api_username = SpreeGladly::Config.gladly_api_username
        @api_key = SpreeGladly::Config.gladly_api_key
        @base_url = SpreeGladly::Config.gladly_api_base_url
        @payload = payload
      end

      def call
        return if base_url.blank?

        perform_request
      end

      def perform_request
        post_request if request_method.eql?(:post)
      end

      def post_request
        uri = URI(request_url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 20
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.path)
        request.basic_auth(api_username, api_key)
        request.body = payload.to_json

        response = http.request(request)

        formatted_response(response: response)
      end

      def request_url
        "#{base_url}#{resource_url}"
      end

      def request_method
        not_implemented_error
      end

      def resource_url
        not_implemented_error
      end

      private

      attr_reader :base_url, :api_key, :api_username, :payload

      def formatted_response(response:)
        parse_error(error: response) if net_http_errors.include?(response.class.to_s)

        { id: JSON.parse(response.body)['id'], code: response.code, status: response.msg }
      end
    end
  end
end
