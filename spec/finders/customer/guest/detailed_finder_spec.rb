# frozen_string_literal: true

require 'spec_helper'

describe Customer::Guest::DetailedFinder do
  subject { described_class.new(email: external_customer_id) }

  describe '#execute' do
    let!(:guest_orders) { create_list(:completed_order_with_pending_payment, 3, user: nil, email: 'guest@example.com') }
    let!(:order) { create_list(:completed_order_with_pending_payment, 2) }

    context 'given valid email' do
      let(:external_customer_id) { 'guest@example.com' }

      it 'return query result' do
        expect(Spree::Order.all.size).to eq 5
        result = subject.execute
        expect(result.customer.email).to eq external_customer_id
        expect(result.transactions.size).to eq 3
      end
    end

    context 'given invalid email' do
      let(:external_customer_id) { '' }

      it 'return query result' do
        result = subject.execute

        expect(result.customer).to eq []
        expect(result.transactions).to eq []
        expect(result.guest).to eq true
      end
    end
  end
end
