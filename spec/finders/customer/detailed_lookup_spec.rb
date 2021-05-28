require 'spec_helper'

describe Customer::DetailedLookup do
  subject { described_class.new(params: params) }

  describe '#execute' do
    context 'customers with order' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:customer1) { create(:user_with_addreses) }
      let!(:order) { create(:completed_order_with_pending_payment, user: customer) }
      let!(:order1) { create(:completed_order_with_pending_payment, user: customer1) }

      let(:params) do
        {
          query: {
            emails: [customer.email],
            phones: [customer1.ship_address.phone],
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
      let!(:customer1) { create(:user_with_addreses) }

      let(:params) do
        {
          query: {
            emails: [customer.email],
            phones: [customer1.ship_address.phone],
            name: customer.ship_address.full_name
          }
        }
      end

      it 'return empty array' do
        result = subject.execute
        expect(result).to eq []
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
