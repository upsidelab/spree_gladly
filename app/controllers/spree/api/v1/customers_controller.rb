# frozen_string_literal: true

module Spree
  module Api
    module V1
      class CustomersController < ::ApplicationController
        before_action :validate_signature, only: :lookup
        before_action :validate_params, only: :lookup

        rescue_from ::Auth::Error, with: :authorization_error

        def lookup
          lookup_level = params['lookupLevel'].downcase.to_sym
          collection = customer_lookup(type: lookup_level).execute

          # add some general class where dev be able to configure out serializers
          render json: serialize_collection(
            type: lookup_level,
            collection: collection
          ).serializable_hash
        end

        private

        def serialize_collection(type:, collection:)
          {
            detailed: Customer::DetailedSerializer.new(collection, { is_collection: true }),
            basic: Customer::BasicSerializer.new(collection)
          }[type]
        end

        # add some general class where dev be able to configure out those
        def customer_lookup(type:)
          {
            detailed: Customer::DetailedLookup.new(params: params),
            basic: Customer::BasicLookup.new(params: params)
          }[type]
        end

        def validate_signature
          ::Auth::SignatureValidator.new.validate(request)
        end

        def authorization_error(error)
          errors = [{ attr: 'Gladly-Authorization', code: error.class.to_s, detail: error.to_s }]
          render json: { errors: errors }, status: 401
        end

        def validate_params
          true # add custom validator
        end
      end
    end
  end
end
