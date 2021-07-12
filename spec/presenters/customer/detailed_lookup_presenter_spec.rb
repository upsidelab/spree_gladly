require 'spec_helper'

describe Customer::DetailedLookupPresenter, as: :presenter do
  subject { described_class.new(resource: resource) }

  describe '#to_h', -> { true }
end
