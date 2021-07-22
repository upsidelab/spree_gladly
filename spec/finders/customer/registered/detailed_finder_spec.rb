# frozen_string_literal: true

require 'spec_helper'

describe Customer::Registered::DetailedFinder do
  subject { described_class.new(customer: customer) }

  describe '#execute' do
    context 'customer with orders' do
      let!(:order1) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-01 0:00:00 UTC')
      end
      let!(:order2) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-02 0:00:00 UTC')
      end
      let!(:order3) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-03 0:00:00 UTC')
      end
      let!(:order4) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-04 0:00:00 UTC')
      end
      let!(:order5) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-05 0:00:00 UTC')
      end
      let!(:customer) { create(:user_with_addreses) }

      it 'return customer orders' do
        result = subject.execute
        expect(result.customer.id).to eq customer.id
        expect(result.transactions.size).to eq 5
        expect(result.guest).to eq false
      end
    end

    context 'customer with orders when orders are limited and sorted' do
      before do
        allow(SpreeGladly::Config).to receive(:order_limit).and_return(2)
        allow(SpreeGladly::Config).to receive(:order_sorting).and_return({ created_at: :desc })
      end

      let!(:order1) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-01 0:00:00 UTC')
      end
      let!(:order2) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-02 0:00:00 UTC')
      end
      let!(:order3) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-03 0:00:00 UTC')
      end
      let!(:order4) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-04 0:00:00 UTC')
      end
      let!(:order5) do
        create(:completed_order_with_pending_payment, user: customer, created_at: '2021-01-05 0:00:00 UTC')
      end
      let!(:customer) { create(:user_with_addreses) }

      it 'return customer orders' do
        result = subject.execute
        expect(result.customer.id).to eq customer.id
        expect(result.transactions.size).to eq 2
        expect(result.transactions).to eq([order5, order4])
        expect(result.guest).to eq false
      end
    end

    context 'customer without orders' do
      let!(:customer) { create(:user_with_addreses) }

      it 'return empty array' do
        result = subject.execute

        expect(result.customer.id).to eq customer.id
        expect(result.transactions.size).to eq 0
        expect(result.guest).to eq false
      end
    end

    context 'guest orders' do
      let!(:customer) { create(:user_with_addreses) }

      context 'only guest orders' do
        let!(:other_customer) { create(:user) }
        let!(:order) { create(:completed_order_with_pending_payment, user: other_customer) }
        let!(:guest_order) { create(:completed_order_with_pending_payment, user: nil, email: customer.email) }

        it 'return orders' do
          expect(Spree::Order.all.size).to eq 2
          result = subject.execute
          expect(result.transactions.size).to eq 1
          expect(result.transactions.first.id).to eq guest_order.id
          expect(result.guest).to eq false
        end
      end

      context 'guest and signed orders' do
        let!(:order) { create(:completed_order_with_pending_payment, user: customer) }
        let!(:guest_order) { create(:completed_order_with_pending_payment, user: nil, email: customer.email) }

        it 'return customer orders' do
          expect(Spree::Order.all.size).to eq 2
          result = subject.execute
          expect(result.customer.email).to eq customer.email
          expect(result.transactions.size).to eq 2
          expect(result.guest).to eq false
        end
      end
    end

    context 'without results' do
      let!(:customer) { create(:user) }
      let!(:other_customer) { create(:user) }
      let!(:order) { create(:completed_order_with_pending_payment, user: other_customer) }
      let!(:guest_order) { create(:completed_order_with_pending_payment, user: nil, email: other_customer.email) }

      it 'return empty transactions result' do
        expect(Spree::Order.all.size).to eq 2
        result = subject.execute
        expect(result.customer.id).to eq customer.id
        expect(result.transactions.size).to eq 0
        expect(result.guest).to eq false
      end
    end

    context 'with invalid params' do
      context 'without query key' do
        let(:customer) { nil }

        it 'return empty array' do
          result = subject.execute
          expect(result.customer).to eq []
          expect(result.transactions).to eq []
          expect(result.guest).to eq false
        end
      end
    end
  end
end
