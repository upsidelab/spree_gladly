# frozen_string_literal: true

require 'spree_core'
require 'spree_extension'
require 'spree_gladly/version'
require 'spree_gladly/engine'
require 'deface'

module SpreeGladly
  def self.setup
    yield Config
  end
end
