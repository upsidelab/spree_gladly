# frozen_string_literal: true

require 'spec_helper'

describe Customer::Guest::BasicFinder do
  subject { described_class.new(emails: emails, options: options) }

  describe '#execute' do
    let!(:order) { create(:completed_order_with_pending_payment, user: nil, email: 'guest0@example.com') }
    let!(:order1) { create(:completed_order_with_pending_payment, user: nil, email: 'guest1@example.com') }
    let!(:order2) { create(:completed_order_with_pending_payment, user: nil, email: 'guest2@example.com') }

    context 'given valid params' do
      context 'given emails array' do
        let(:emails) { [order.email, order1.email] }
        let(:options) { {} }

        it 'return expected result' do
          expect(Spree::Order.all.size).to eq 3

          result = subject.execute

          expect(result.size).to eq 2
          expect(result.pluck(:email).sort).to eq emails.sort
        end
      end

      context 'given emails array and options hash' do
        let!(:user) { create(:user_with_addresses, email: 'guest2@example.com') }
        let!(:order2) { create(:completed_order_with_pending_payment, user: user) }
        let(:emails) { [order1.email, order2.email] }
        let(:options) { { excluded_emails: [order2.email] } }

        it 'return expected result' do
          expect(Spree::Order.all.size).to eq 3

          result = subject.execute

          expect(result.size).to eq 1
          expect(result.first.email).to eq order1.email
        end
      end

      context 'return single customer per result' do
        let!(:order) { create(:completed_order_with_pending_payment, user: nil, email: 'guest@example.com') }
        let!(:order1) { create_list(:completed_order_with_pending_payment, 3, user: nil, email: 'guest1@example.com') }

        let(:emails) { [order.email, order1.first.email] }
        let(:options) { {} }

        it 'return expected result' do
          result = subject.execute

          expect(result.size).to eq emails.size
        end
      end
    end

    context 'given invalid or empty params' do
      let(:emails) { [] }
      let(:options) { {} }

      it 'return empty array' do
        result = subject.execute
        expect(result).to eq []
      end
    end
  end
end
