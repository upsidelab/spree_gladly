# frozen_string_literal: true

module Customer
  module Guest
    class BasicFinder
      def initialize(emails:, options: {})
        @emails = emails
        @options = options
      end

      def execute
        return [] if emails.empty?

        byebug
        guest_customers.uniq(&:email)
      end

      private

      attr_reader :emails, :options

      def guest_customers
        Spree::Order
          .where(user_id: nil)
          .where(email: search_emails)
          .order(created_at: :desc)
      end

      def search_emails
        return emails - options[:excluded_emails] if options[:excluded_emails].present?

        emails
      end
    end
  end
end
