# frozen_string_literal: true

require 'spec_helper'

describe 'Update Gladly Settings spec', type: :feature do
  stub_authorization!

  describe 'signing_key' do
    around do |example|
      signing_key = SpreeGladly::Config.signing_key
      example.run
      SpreeGladly::Config.signing_key = signing_key
    end

    it 'updates gladly settings' do
      visit '/admin/gladly_settings/edit'

      fill_in 'signing_key', with: 'test-apikey-1'
      click_button 'Save Gladly preferences'

      expect(SpreeGladly::Config.signing_key).to eq 'test-apikey-1'
      expect(current_path).to eq '/admin/gladly_settings/edit'
    end
  end

  describe 'signing_threshold' do
    around do |example|
      signing_threshold = SpreeGladly::Config.signing_threshold
      example.run
      SpreeGladly::Config.signing_threshold = signing_threshold
    end

    it 'updates signing threshold given an int' do
      visit '/admin/gladly_settings/edit'

      fill_in 'signing_threshold', with: '15'
      click_button 'Save Gladly preferences'

      expect(SpreeGladly::Config.signing_threshold).to eq 15
      expect(current_path).to eq '/admin/gladly_settings/edit'
    end

    it 'updates signing threshold given an empty value' do
      visit '/admin/gladly_settings/edit'

      fill_in 'signing_threshold', with: ''
      click_button 'Save Gladly preferences'

      expect(SpreeGladly::Config.signing_threshold).to eq 0
      expect(current_path).to eq '/admin/gladly_settings/edit'
    end

    it 'does not update signing threshold given an invalid value' do
      SpreeGladly::Config.signing_threshold = 123
      visit '/admin/gladly_settings/edit'

      fill_in 'signing_threshold', with: 'asdf'
      click_button 'Save Gladly preferences'

      expect(SpreeGladly::Config.signing_threshold).to eq 123
      expect(current_path).to eq '/admin/gladly_settings/edit'
      expect(page).to have_content 'Signing Threshold should be empty, 0 or positive'
    end
  end
end
