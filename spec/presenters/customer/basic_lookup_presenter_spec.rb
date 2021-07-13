# frozen_string_literal: true

require 'spec_helper'

describe Customer::BasicLookupPresenter, as: :presenter do
  subject { described_class.new(resource: resource) }

  describe '#to_h' do
    context 'only guest customers' do
      let!(:order) { create(:completed_order_with_pending_payment, user_id: nil, email: 'guest@example.com') }
      let!(:order1) { create(:completed_order_with_pending_payment, user_id: nil, email: 'guest1@example.com') }
      let!(:guest_customers) { [order, order1] }
      let(:resource) { OpenStruct.new(guest_customers: guest_customers, registered_customers: []) }

      it 'return formatted payload' do
        result = subject.to_h

        expect(result.empty?).to eq false
        expect(result.first.keys).to eq %i[externalCustomerId address name emails phones]
      end
    end

    context 'only registered customers' do
      let!(:customer) { create(:user_with_addresses) }
      let!(:customer1) { create(:user_with_addresses) }
      let!(:registered_customers) { [customer, customer1] }
      let(:resource) { OpenStruct.new(guest_customers: [], registered_customers: registered_customers) }

      it 'return formatted payload' do
        result = subject.to_h

        expect(result.empty?).to eq false
        expect(result.first.keys).to eq %i[externalCustomerId spreeId address name emails phones]
      end
    end

    context 'registered and guest customers' do
      let!(:order) { create(:completed_order_with_pending_payment, user_id: nil, email: 'guest@example.com') }
      let!(:order1) { create(:completed_order_with_pending_payment, user_id: nil, email: 'guest1@example.com') }
      let!(:customer) { create(:user_with_addresses) }
      let!(:customer1) { create(:user_with_addresses) }
      let!(:guest_customers) { [order, order1] }
      let!(:registered_customers) { [customer, customer1] }
      let(:resource) { OpenStruct.new(guest_customers: guest_customers, registered_customers: registered_customers) }

      it 'return formatted payload' do
        result = subject.to_h
        registered_format = result.find { |i| i[:externalCustomerId] == customer.email }.keys
        guest_format = result.find { |i| i[:externalCustomerId] == order.email }.keys

        expect(registered_format).to eq %i[externalCustomerId spreeId address name emails phones]
        expect(guest_format).to eq %i[externalCustomerId address name emails phones]
      end
    end
  end
end
