module Customer
  class BasicSerializer
    include JSONAPI::Serializer

    attribute :externalCustomerId, &:id

    attributes :email

    attribute :name do |user|
      user_addr = user.ship_address || user.bill_address
      user_addr&.full_name
    end

    attribute :phone do |user|
      user_addr = user.ship_address || user.bill_address
      user_addr&.phone
    end
  end
end
