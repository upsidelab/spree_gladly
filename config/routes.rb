Spree::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      post '/customer/lookup', to: 'customer#lookup', as: :customer_lookup
    end
  end
end
