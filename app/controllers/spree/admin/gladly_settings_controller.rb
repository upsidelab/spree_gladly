module Spree
  module Admin
    class GladlySettingsController < ::Spree::Admin::BaseController
      def edit
        @signing_key = SpreeGladly::Config.signing_key
        @signing_threshold = SpreeGladly::Config.signing_threshold
      end
    end
  end
end
