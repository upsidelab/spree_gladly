module SpreeGladly
  class CustomerSerializer
    include JSONAPI::Serializer

    attributes :email
  end
end
