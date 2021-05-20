FACTORY_BOT_CLASS = defined?(FactoryGirl) ? FactoryGirl : FactoryBot

FACTORY_BOT_CLASS.define do
  gem_root = File.dirname(File.dirname(File.dirname(__FILE__)))

  Dir[File.join(gem_root, 'spec', 'factories', '**', '*.rb')].sort.each do |factory|
    require(factory)
  end
end
