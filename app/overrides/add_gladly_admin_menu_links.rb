# frozen_string_literal: true

Deface::Override.new(
  virtual_path: 'spree/admin/shared/sub_menu/_configuration',
  name: 'add_gladly_admin_menu_links',
  insert_bottom: "ul[data-hook='admin_configurations_sidebar_menu']",
  # rubocop:disable Layout/LineLength
  text: "<%= configurations_sidebar_menu_item('Gladly Settings', edit_admin_gladly_settings_path) if can? :manage, Spree::Config %>"
  # rubocop:enable Layout/LineLength
)
