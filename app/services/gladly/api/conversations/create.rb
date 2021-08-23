# frozen_string_literal: true

module Gladly
  module Api
    module Conversations
      class Create < Gladly::Api::Client
        def request_method
          :post
        end

        def resource_url
          '/api/v1/conversation-items'
        end
      end
    end
  end
end
