# frozen_string_literal: true

require 'spec_helper'

describe Customer::DetailedLookupPresenter, as: :presenter do
  subject { described_class.new(resource: resource) }

  describe '#to_h' do
    context 'registered customer' do
      let!(:customer) { create(:user_with_addresses) }
      let!(:transactions) { create_list(:completed_order_with_pending_payment, 2) }
      let(:resource) { OpenStruct.new(customer: customer, transactions: transactions, guest: false) }

      it 'return formatted payload' do
        result = subject.to_h

        expect(result.first.keys).to eq %i[externalCustomerId name address emails phones customAttributes transactions]
        expect(result.empty?).to eq false
      end
    end

    context 'guest customer' do
      let!(:customer) { transactions.first }
      # rubocop:disable Layout/LineLength
      let!(:transactions) { create_list(:completed_order_with_pending_payment, 3, user_id: nil, email: 'guest@example.com') }
      # rubocop:enable Layout/LineLength
      let(:resource) { OpenStruct.new(customer: customer, transactions: transactions, guest: true) }

      it 'return formatted payload' do
        result = subject.to_h

        expect(result.first.keys).to match_array %i[externalCustomerId emails customAttributes transactions]
        expect(result.empty?).to eq false
      end
    end

    context 'given no customer' do
      let(:resource) { OpenStruct.new(customer: [], transactions: []) }

      it 'return empty array' do
        result = subject.to_h

        expect(result).to eq []
      end
    end
  end
end
