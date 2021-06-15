# frozen_string_literal: true

module Spree
  module Admin
    class GladlySettingsController < ::Spree::Admin::BaseController
      POSITIVE_INT_REGEX = /\A[0-9]+\Z/.freeze

      def edit
        @signing_key = SpreeGladly::Config.signing_key
        @signing_threshold = SpreeGladly::Config.signing_threshold
      end

      def update
        if params[:signing_threshold].present? && params[:signing_threshold] !~ POSITIVE_INT_REGEX
          flash[:error] = Spree.t('spree_gladly.signing_threshold_error')
        else
          set_signing_key
          set_signing_threshold
          flash[:success] = Spree.t('spree_gladly.save_success')
        end

        redirect_to edit_admin_gladly_settings_path
      end

      private

      def set_signing_key
        SpreeGladly::Config.signing_key = params[:signing_key] if params.key?('signing_key')
      end

      def set_signing_threshold
        return unless params.key?(:signing_threshold)

        SpreeGladly::Config.signing_threshold = [0, params[:signing_threshold].to_i].max
      end
    end
  end
end
