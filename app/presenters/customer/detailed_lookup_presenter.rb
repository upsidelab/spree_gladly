module Customer
  class DetailedLookupPresenter
    include Spree::Core::Engine.routes.url_helpers
    include Spree::BaseHelper

    def initialize(resource:)
      @resource = resource
    end

    def to_h
      return [] unless resource.customer.present?

      detailed_payload
    end

    private

    attr_reader :resource

    def detailed_payload
      [
        {
          externalCustomerId: resource.customer&.id.to_s,
          name: address&.full_name,
          address: address.to_s&.gsub('<br/>', ' '),
          emails: emails,
          phones: phones,
          customAttributes: custom_attributes,
          transactions: transactions
        }
      ]
    end

    def custom_attributes
      {
        lifetimeValue: lifetime_value,
        totalOrderCount: resource.transactions.size.to_s,
        memberSince: pretty_time(resource.customer.created_at).to_s,
        customerLink: customer_profile_url(resource.customer),
        returnCount: 4.to_s # framebrigde
      }
    end

    def transactions
      resource.transactions.map do |transaction|
        {
          type: 'ORDER',
          orderStatus: transaction.state,
          orderNumber: transaction.number,
          products: transaction_products(transaction: transaction),
          orderLink: order_url(transaction),
          note: transaction&.special_instructions.to_s,
          orderTotal: "#{transaction.total} #{transaction.currency}",
          createdAt: transaction.created_at
        }
      end
    end

    def transaction_products(transaction:)
      transaction.line_items.map do |item|
        {
          name: item.variant.name,
          status: item_status(item: item),
          sku: item.variant.sku,
          quantity: item.quantity.to_s,
          total: item.total,
          unitPrice: "#{item.price} #{item.order.currency}",
          imageUrl: item_image_url(item: item),
          workOrderUrl: 'https://example.com', # framebridge
          trackingUrl: 'https://fedex.com' # framebridge
        }
      end
    end

    def customer_profile_url(customer)
      edit_admin_user_url(id: customer.id, host: Rails.application.routes.default_url_options[:host])
    end

    def order_url(transaction)
      edit_admin_order_url(id: transaction.number, host: Rails.application.routes.default_url_options[:host])
    end

    def lifetime_value
      return '0' if resource.transactions.empty?

      value = resource.transactions.sum(&:total).to_s

      "#{value} #{resource.transactions.first.currency}"
    end

    def item_image_url(item:)
      return '' if item.product.images.empty?

      item.product.images.first&.attachment&.url
    end

    def item_status(item:)
      item.sufficient_stock? ? 'fulfilled' : 'cancelled'
    end

    def emails
      [
        {
          original: resource.customer.email
        }
      ]
    end

    def phones
      [
        {
          original: address&.phone
        }
      ]
    end

    def address
      @address ||= resource.customer.ship_address
    end
  end
end
