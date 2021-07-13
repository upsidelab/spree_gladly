# frozen_string_literal: true

module Customer
  module Guest
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
        resource.map do |guest_customer|
          {
            externalCustomerId: guest_customer.email,
            address: guest_customer&.bill_address.to_s&.gsub('<br/>', ' '),
            name: guest_customer&.bill_address&.full_name.to_s,
            emails: customer_emails(guest_customer),
            phones: customer_phones(guest_customer)
          }
        end
      end

      def customer_emails(guest_customer)
        [
          {
            original: guest_customer.email
          }
        ]
      end

      def customer_phones(guest_customer)
        [
          {
            original: guest_customer&.bill_address&.phone.to_s
          }
        ]
      end
    end
  end
end
