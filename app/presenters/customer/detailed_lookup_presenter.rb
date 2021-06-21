require 'byebug'
module Customer
  class DetailedLookupPresenter
    def initialize(resource:)
      @resource = resource
    end

    def to_h
      return {} unless resource.customer.present?

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
          customAttributes: customAttributes,
          transactions: transactions
        }
      ]
    end

    def customAttributes
      {
        lifetimeValue: resource.customer.created_at,
        totalOrderCount: resource.transactions.size.to_s
      }
    end

    def transactions
      resource.transactions.map do |transaction|
        {
          type: 'ORDER',
          products: transaction_products(transaction: transaction),
          orderLink: '',
          note: transaction&.special_instructions.to_s,
          orderTotal: transaction.total,
          orderNumber: transaction.number,
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
          quantity: item.quantity,
          total: item.total,
          unitPrice: item.price,
          imageUrl: item.product.images.first&.attachment&.url || ''
        }
      end
    end

    def item_status(item:)
      item.sufficient_stock? ? 'fulfilled' : 'cancelled'
    end

    def emails
      [
        {
          normalized: resource.customer.email.downcase,
          original: resource.customer.email,
          primary: true
        }
      ]
    end

    def phones
      [
        {
          original: address&.phone,
          primary: true
        }
      ]
    end

    def address
      @address ||= resource.customer.ship_address || resource.bill_address
    end
  end
end
