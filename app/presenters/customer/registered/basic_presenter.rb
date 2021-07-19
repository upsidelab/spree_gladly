# frozen_string_literal: true

module Customer
  module Registered
    class BasicPresenter
      def initialize(resource:)
        @resource = resource
      end

      def to_h
        return [] if resource.empty?

        basic_payload
      end

      private

      attr_reader :resource

      def basic_payload
        resource.map do |user|
          {
            externalCustomerId: user.email,
            customAttributes: {
              spreeId: user.id
            },
            address: formatted_address(user),
            name: address(user)&.full_name.to_s,
            emails: customer_emails(user),
            phones: customer_phones(user)
          }
        end
      end

      def customer_emails(user)
        [
          {
            original: user.email
          }
        ]
      end

      def customer_phones(user)
        [
          {
            original: address(user)&.phone.to_s
          }
        ]
      end

      def address(user)
        user.bill_address || user.orders.first&.bill_address
      end

      def formatted_address(user)
        Customer::AddressPresenter.new(address(user)).to_s
      end
    end
  end
end
