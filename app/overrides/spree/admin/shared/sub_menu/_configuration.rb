Deface::Override.new(
  virtual_path: 'spree/admin/shared/sub_menu/_configuration',
  name: 'add_gladly_admin_menu_links',
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']"
) do
  <<~HTML
    <%= configurations_sidebar_menu_item('Gladly Settings', edit_admin_gladly_settings_path) %>
  HTML
end
