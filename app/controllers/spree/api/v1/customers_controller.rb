# frozen_string_literal: true

module Spree
  module Api
    module V1
      class CustomersController < ::ApplicationController
        skip_before_action :verify_authenticity_token, only: :lookup
        before_action :validate_signature, only: :lookup
        before_action :validate_params, only: :lookup

        rescue_from ::Auth::InvalidSignatureError, with: :authorization_error
        rescue_from ::Auth::MissingKeyError, with: :authorization_error
        rescue_from ::Auth::HeaderParseError, with: :authorization_error

        def lookup
          lookup_level = params['lookupLevel'].downcase.to_sym
          collection = customer_lookup(type: lookup_level).execute

          render json: serialize_collection(
            type: lookup_level,
            collection: collection
          ), status: 200
        end

        private

        def serialize_collection(type:, collection:)
          klass     = type == :basic ? :basic_lookup_presenter : :detailed_lookup_presenter
          presenter = SpreeGladly::Config.send(klass).send :new, resource: collection

          { results: presenter.to_h }
        end

        def customer_lookup(type:)
          if type == :basic
            Customer::BasicLookup.new(params: params)
          else
            Customer::DetailedLookup.new(params: params)
          end
        end

        def validate_signature
          ::Auth::SignatureValidator.new(SpreeGladly::Config.signing_key,
                                         SpreeGladly::Config.signing_threshold).validate(request)
        end

        def authorization_error(error)
          errors = [{ attr: 'Gladly-Authorization', code: error.class.to_s, detail: error.to_s }]
          render json: { errors: errors }, status: 401
        end

        def validate_params
          result = LookupValidator.new.call(params.permit!.to_h.deep_symbolize_keys)
          render json: { errors: result.format_errors }, status: 422 unless result.success?
        end
      end
    end
  end
end
