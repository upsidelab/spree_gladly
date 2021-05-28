module Customer
  class DetailedSerializer
    include JSONAPI::Serializer

    attributes :number, :email, :line_items, :shipments

    attribute :customer do |obj|
      Customer::BasicSerializer.new(obj.user).serializable_hash
    end
  end
end
