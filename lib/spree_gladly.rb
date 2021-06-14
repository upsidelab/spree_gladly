# frozen_string_literal: true

require 'spree_core'
require 'spree_extension'
require 'spree_gladly/version'
require 'spree_gladly/engine'

module SpreeGladly
  mattr_accessor :basic_lookup_presenter
  @@basic_lookup_presenter = nil

  mattr_accessor :detailed_lookup_presenter
  @@detailed_lookup_presenter = nil

  def self.setup
    yield Config
  end
end
