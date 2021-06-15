# frozen_string_literal: true

require 'spec_helper'

describe 'Admin sidebar menu Gladly', type: :feature do
  stub_authorization!

  it 'render gladly settings in admin page' do
    visit '/admin'

    expect(page).to have_content('Configurations')
    expect(page).to have_content('General Settings')
    expect(page).to have_selector("ul[data-hook='admin_configurations_sidebar_menu']")

    expect(page).to have_content('Gladly Settings')
    expect(page).to have_selector("a[href='/admin/gladly_settings/edit']")
  end
end
