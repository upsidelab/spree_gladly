module Spree
  module Api
    module V1
      class CustomerController < ::ApplicationController
        before_action :validate_params, only: :lookup

        def lookup
          byebug
          render json: :ok
        end

        private

        def validate_params
          true
          # add custom validator
        end
      end
    end
  end
end
