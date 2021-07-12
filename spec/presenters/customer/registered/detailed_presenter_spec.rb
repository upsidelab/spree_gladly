# frozen_string_literal: true

require 'spec_helper'

describe Customer::Registered::DetailedPresenter, as: :presenter do
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
        expect(results.first.keys).to match_array %i[externalCustomerId name address emails phones customAttributes transactions]
        expect(results.first[:transactions][0].keys).to match_array %i[type orderStatus orderNumber guest products orderLink note orderTotal createdAt]
        expect(results.first[:transactions][0][:products].first.keys).to match_array %i[name status sku quantity total unitPrice imageUrl]
        # rubocop:enable Layout/LineLength
      end
    end

    context 'with given resource without transactions' do
      let!(:customer) { create(:user_with_addresses) }
      let!(:transactions) { [] }

      it 'return formatted results' do
        results = subject.to_h
        expect(results.size).to eq 1
        # rubocop:disable Layout/LineLength
        expect(results.first.keys).to match_array %i[externalCustomerId name address emails phones customAttributes transactions]
        # rubocop:enable Layout/LineLength
        expect(results.first[:transactions]).to be_empty
      end
    end

    context 'with given empty resources' do
      let!(:customer) { [] }
      let!(:transactions) { [] }

      it 'return empty hash' do
        result = subject.to_h
        expect(result.is_a?(Array)).to eq true
        expect(result.empty?).to eq true
      end
    end
  end
end