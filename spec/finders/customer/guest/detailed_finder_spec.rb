# frozen_string_literal: true

require 'spec_helper'

describe Customer::Guest::DetailedFinder do
  subject { described_class.new(email: external_customer_id) }

  describe '#execute' do
    let!(:order1) do
      create(:completed_order_with_pending_payment, user: nil, email: 'guest@example.com',
                                                    created_at: '2021-01-01 0:00:00 UTC')
    end
    let!(:order2) do
      create(:completed_order_with_pending_payment, user: nil, email: 'guest@example.com',
                                                    created_at: '2021-01-02 0:00:00 UTC')
    end
    let!(:order3) do
      create(:completed_order_with_pending_payment, user: nil, email: 'guest@example.com',
                                                    created_at: '2021-01-03 0:00:00 UTC')
    end
    let!(:order4) do
      create(:completed_order_with_pending_payment, user: nil, email: 'guest@example.com',
                                                    created_at: '2021-01-04 0:00:00 UTC')
    end
    let!(:order5) do
      create(:completed_order_with_pending_payment, user: nil, email: 'guest@example.com',
                                                    created_at: '2021-01-05 0:00:00 UTC')
    end
    let!(:order) { create_list(:completed_order_with_pending_payment, 2) }

    context 'given valid email' do
      let(:external_customer_id) { 'guest@example.com' }

      it 'return query result' do
        expect(Spree::Order.all.size).to eq 7
        result = subject.execute
        expect(result.customer.email).to eq external_customer_id
        expect(result.transactions.size).to eq 5
      end
    end

    context 'when limiting amount and sorting of orders' do
      before do
        allow(SpreeGladly::Config).to receive(:order_limit).and_return(2)
        allow(SpreeGladly::Config).to receive(:order_sorting).and_return({ created_at: :desc })
      end

      let(:external_customer_id) { 'guest@example.com' }

      it 'returns latest query result limited to order limit' do
        result = subject.execute
        expect(result.customer.email).to eq external_customer_id
        expect(result.transactions.size).to eq 2
        expect(result.transactions).to eq([order5, order4])
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
