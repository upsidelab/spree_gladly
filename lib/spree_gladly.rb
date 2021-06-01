# frozen_string_literal: true

require 'spree_core'
require 'spree_extension'
require 'jsonapi/serializer'
require 'spree_gladly/version'
require 'spree_gladly/engine'

module SpreeGladly
  mattr_accessor :signing_key
  @@signing_key = nil

  mattr_accessor :signing_threshold
  @@signing_threshold = nil

  def self.setup
    yield self
  end
end
