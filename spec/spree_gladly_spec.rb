# frozen_string_literal: true

RSpec.describe SpreeGladly do
  it 'has a version number' do
    expect(SpreeGladly::VERSION).not_to be nil
  end

  describe '.setup' do
    it 'yields self' do
      described_class.setup do |config|
        expect(config).to eq described_class
      end
    end
  end
end
