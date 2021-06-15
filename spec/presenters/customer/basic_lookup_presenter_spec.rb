require 'spec_helper'

describe Customer::BasicLookupPresenter, as: :presenter do
  subject { described_class.new(resource: resource) }

  describe '#to_h' do
    context 'with given resources' do
      let!(:resource) { create_list(:user_with_addreses, 4) }

      it 'return formatted results' do
        results = subject.to_h
        expect(results.size).to eq 4
        expect(results.first.keys).to eq %i[externalCustomerId name email phone]
      end
    end

    context 'with given empty resources' do
      let(:resource) { [] }

      it 'return empty hash' do
        result = subject.to_h

        expect(result.is_a?(Hash)).to eq true
      end
    end
  end
end
