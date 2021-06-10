# frozen_string_literal: true

require 'spree_core'
require 'spree_extension'
require 'spree_gladly/version'
require 'spree_gladly/engine'

module SpreeGladly
  @@signing_key = nil

  mattr_accessor :signing_threshold
  @@signing_threshold = nil

  mattr_accessor :basic_lookup_presenter
  @@basic_lookup_presenter = nil

  mattr_accessor :detailed_lookup_presenter
  @@detailed_lookup_presenter = nil

  def self.setup
    yield self
  end

  def self.signing_key
    Spree::Config.get('spree_gladly/configuration/signing_key')
  end

  def self.signing_key=(key)
    Spree::Config.set('spree_gladly/configuration/signing_key' => key)
  end
end
