module Customer
  class DetailedSerializer
    include JSONAPI::Serializer

    attribute :externalCustomerId do |user|
      user.id.to_s
    end

    attribute :name do |user|
      user_addr = user.ship_address || user.bill_address
      user_addr&.full_name
    end

    attribute :address do |user|
      user_addr = user.ship_address || user.bill_address
      user_addr&.to_s&.gsub('<br/>', ' ')
    end

    attribute :emails do |user|
      email = user.email
      [{
        normalized: email.downcase,
        original: email,
        primary: true
      }]
    end

    attribute :phones do |user|
      user_addr = user.ship_address || user.bill_address

      if user_addr&.phone.present?
        [{
          original: user_addr.phone,
          primary: true
        }]
      else
        []
      end
    end

    attribute :transactions do |_user|
      []
    end
  end
end
