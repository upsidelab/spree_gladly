require 'spec_helper'

describe Customer::DetailedLookup do
  subject { described_class.new(params: params) }

  describe '#execute' do
    context 'customers with order' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:other_customer) { create(:user_with_addreses) }
      let!(:order) { create(:completed_order_with_pending_payment, user: customer) }
      let!(:order1) { create(:completed_order_with_pending_payment, user: other_customer) }

      let(:params) do
        {
          query: {
            emails: [customer.email],
            phones: [other_customer.ship_address.phone],
            name: customer.ship_address.full_name
          }
        }
      end

      it 'return customers orders' do
        result = subject.execute
        expect(result.size).to eq 2
      end
    end

    context 'customers without orders' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:other_customer) { create(:user_with_addreses) }

      let(:params) do
        {
          query: {
            emails: [customer.email],
            phones: [other_customer.ship_address.phone],
            name: customer.ship_address.full_name
          }
        }
      end

      it 'return empty array' do
        result = subject.execute
        expect(result).to eq []
      end
    end

    context 'guest orders' do
      let!(:customer) { create(:user_with_addreses) }

      context 'only guest orders' do
        let!(:other_customer) { create(:user) }
        let!(:order) { create(:completed_order_with_pending_payment, user: other_customer) }
        let!(:guest_order) { create(:completed_order_with_pending_payment, user: nil, email: customer.email) }
        let(:params) do
          {
            query: {
              emails: [customer.email],
              name: customer.ship_address.full_name
            }
          }
        end

        it 'return orders' do
          expect(Spree::Order.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 1
          expect(result.first.id).to eq guest_order.id
        end
      end

      context 'guest and signed orders' do
        let!(:order) { create(:completed_order_with_pending_payment, user: customer) }
        let!(:guest_order) { create(:completed_order_with_pending_payment, user: nil, email: customer.email) }
        let(:params) do
          {
            query: {
              emails: [customer.email],
              name: customer.ship_address.full_name
            }
          }
        end

        it 'return customer orders' do
          expect(Spree::Order.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 2
        end
      end
    end

    context 'without results' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:order) { create(:completed_order_with_pending_payment, user: customer) }
      let!(:guest_order) { create(:completed_order_with_pending_payment, user: nil, email: customer.email) }
      let(:params) do
        {
          query: {
            emails: ['james.bond@example.com']
          }
        }
      end

      it 'return empty result' do
        expect(Spree::Order.all.size).to eq 2
        result = subject.execute
        expect(result.size).to eq 0
      end
    end

    context 'with invalid params' do
      context 'without query key' do
        let(:params) { {} }

        it 'return empty array' do
          result = subject.execute
          expect(result).to eq []
        end
      end

      context 'with empty query key' do
        let(:params) { { query: {} } }

        it 'return empty array' do
          result = subject.execute
          expect(result).to eq []
        end
      end
    end
  end
end
