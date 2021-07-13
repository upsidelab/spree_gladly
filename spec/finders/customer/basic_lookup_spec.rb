# frozen_string_literal: true

require 'spec_helper'

describe Customer::BasicLookup do
  subject { described_class.new(params: params) }

  describe '#execute' do
    context 'registered customers' do
      context 'given valid params' do
        let!(:customer) { create(:user_with_addreses) }
        let!(:other_customer) { create(:user_with_addreses) }
        let(:params) do
          {
            query: {
              emails: [customer.email, other_customer.email],
              phones: [other_customer.ship_address.phone, customer.ship_address.phone]
            }
          }
        end

        it 'return expected result' do
          result = subject.execute
          expect(result.guest_customers).to eq []
          expect(result.registered_customers.empty?).to eq false
        end
      end

      context 'given empty params query' do
        let(:params) do
          {
            query: {
              emails: [],
              phones: []
            }
          }
        end

        it 'return expected result' do
          result = subject.execute

          expect(result.guest_customers).to eq []
          expect(result.registered_customers).to eq []
        end
      end
    end

    context 'guest customers' do
      context 'given valid params' do
        # rubocop:disable Layout/LineLength
        let!(:customer) { create(:completed_order_with_pending_payment, user_id: nil, email: 'guest@example.com') }
        let!(:other_customer) { create(:completed_order_with_pending_payment, user_id: nil, email: 'guest1@example.com') }
        # rubocop:enable Layout/LineLength
        let(:params) do
          {
            query: {
              emails: [customer.email, other_customer.email]
            }
          }
        end

        it 'return expected result' do
          result = subject.execute
          expect(result.guest_customers.empty?).to eq false
          expect(result.registered_customers).to eq []
        end
      end

      context 'given empty params query' do
        let(:params) do
          {
            query: {
              emails: []
            }
          }
        end

        it 'return expected result' do
          result = subject.execute

          expect(result.guest_customers).to eq []
          expect(result.registered_customers).to eq []
        end
      end
    end
  end
end
