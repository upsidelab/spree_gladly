# frozen_string_literal: true

require 'spec_helper'

describe Customer::DetailedLookup do
  subject { described_class.new(params: params) }

  describe '#execute' do
    context 'registered customer' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:orders) { create_list(:completed_order_with_pending_payment, 3, user_id: customer.id) }

      context 'given valid params' do
        let(:params) do
          {
            query: {
              externalCustomerId: customer.email
            }
          }
        end

        it 'return expected result' do
          result = subject.execute

          expect(result.customer.nil?).to eq false
          expect(result.guest).to eq false
          expect(result.transactions.empty?).to eq false
          expect(result.transactions.size).to eq 3
        end
      end

      context 'with guest orders' do
        # rubocop:disable Layout/LineLength
        let!(:guest_orders) { create_list(:completed_order_with_pending_payment, 2, user_id: nil, email: customer.email) }
        # rubocop:enable Layout/LineLength
        let(:params) do
          {
            query: {
              externalCustomerId: customer.email
            }
          }
        end

        it 'return expected result' do
          result = subject.execute

          guest_orders = result.transactions.select { |i| i.user_id.nil? }
          expect(guest_orders.first).to be_present
          expect(guest_orders.size).to eq 2
          expect(result.transactions.size).to eq 5
        end
      end

      context 'given empty param' do
        let(:params) do
          {
            query: {
              externalCustomerId: ''
            }
          }
        end

        it 'return expected result' do
          result = subject.execute

          expect(result.customer).to eq []
          expect(result.transactions).to eq []
        end
      end
    end

    context 'guest customer' do
      let!(:customer) { orders.first }
      let!(:orders) { create_list(:completed_order_with_pending_payment, 3, user_id: nil, email: 'guest@example.com') }
      context 'given valid params' do
        let(:params) do
          {
            query: {
              externalCustomerId: customer.email
            }
          }
        end

        it 'return expected result' do
          result = subject.execute

          expect(result.customer.nil?).to eq false
          expect(result.guest).to eq true
          expect(result.transactions.empty?).to eq false
          expect(result.transactions.size).to eq 3
        end
      end

      context 'given empty param' do
        let(:params) do
          {
            query: {
              externalCustomerId: ''
            }
          }
        end

        it 'return expected result' do
          result = subject.execute

          expect(result.customer).to eq []
          expect(result.transactions).to eq []
        end
      end
    end
  end
end
