require 'factory_bot'

FACTORY_BOT_CLASS = defined?(FactoryGirl) ? FactoryGirl : FactoryBot

FACTORY_BOT_CLASS.find_definitions

RSpec.configure do |config|
  config.include FACTORY_BOT_CLASS::Syntax::Methods
end
