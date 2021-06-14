Spree::Core::Engine.add_routes do
  namespace :admin do
    resource :gladly_settings, only: %i[edit update]
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resource :customers, only: [] do
        post :lookup
      end
    end
  end
end
