require 'spec_helper'

describe 'Edit Gladly Settings spec', type: :feature do
  stub_authorization!

  it 'render edit page' do
    visit '/admin/gladly_settings/edit'

    expect(page).to have_content('Gladly Settings')
  end
end
