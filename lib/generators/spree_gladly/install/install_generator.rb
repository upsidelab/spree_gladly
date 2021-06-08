# frozen_string_literal: true

module SpreeGladly
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def self.source_paths
        paths = superclass.source_paths
        paths << File.expand_path('templates', __dir__)
        paths.flatten
      end

      def copy_initializer
        template 'config/initializers/spree_gladly.rb', 'config/initializers/spree_gladly.rb'
      end
    end
  end
end
