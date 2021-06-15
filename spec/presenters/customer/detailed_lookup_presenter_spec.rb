require 'spec_helper'

describe Customer::DetailedLookupPresenter, as: :presenter do
  subject { described_class.new(resource: resource) }

  describe '#to_h' do
    let(:resource) { OpenStruct.new(customer: customer, transactions: transactions) }

    context 'with given resources' do
      let!(:customer) { create(:user_with_addresses) }
      let!(:transactions) { create_list(:completed_order_with_pending_payment, 4) }

      it 'return formatted results' do
        results = subject.to_h
        expect(results.size).to eq 1
        # Todo add more specs after test against Gladly
        # rubocop:disable Layout/LineLength
        expect(results.first.keys).to eq %i[externalCustomerId name address emails phones transactions]
        expect(results.first[:transactions][0].keys).to eq %i[type products orderLink note orderTotal orderNumber createdAt]
        expect(results.first[:transactions][0][:products].first.keys).to eq %i[name status sku quantity total unitPrice]
        # rubocop:enable Layout/LineLength
      end
    end

    context 'with given empty resources' do
      let!(:customer) { [] }
      let!(:transactions) { [] }

      it 'return empty hash' do
        result = subject.to_h
        expect(result.is_a?(Hash)).to eq true
        expect(result.empty?).to eq true
      end
    end
  end
end
