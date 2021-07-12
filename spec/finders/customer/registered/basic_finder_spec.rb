# frozen_string_literal: true

require 'spec_helper'

describe Customer::Registered::BasicFinder do
  subject { described_class.new(name: name, emails: emails, phones: phones) }

  describe '#execute' do

    context 'with invalid query params' do
      context 'without query key' do
        let(:name) { '' }
        let(:emails) { [] }
        let(:phones) { [] }

        it 'return empty array' do
          result = subject.execute
          expect(result).to eq []
        end
      end

      context 'with empty query key' do
        let(:name) { '' }
        let(:emails) { [] }
        let(:phones) { [] }

        it 'return empty array' do
          result = subject.execute
          expect(result).to eq []
        end
      end
    end

    context 'searching by all params' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:other_customer) { create(:user_with_addreses) }

      let(:name) { customer.bill_address.full_name }
      let(:emails) { [customer.email] }
      let(:phones) { [other_customer.bill_address.phone] }


      it 'return results' do
        expect(Spree.user_class.all.size).to eq 2
        result = subject.execute
        expect(result.size).to eq 2
      end
    end

    context 'searching by email' do
      let!(:customer) { create(:user, email: 'test@example.com') }
      let!(:other_customer) { create(:user, email: 'dummy@example.com') }

      context 'with single email address' do
        let(:name) { '' }
        let(:emails) { [customer.email] }
        let(:phones) { [] }


        it 'return single result' do
          expect(Spree.user_class.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 1
        end
      end

      context 'with multiple email addresses' do
        let(:name) { '' }
        let(:emails) { [customer.email, other_customer.email] }
        let(:phones) { [] }


        it 'return multiple result' do
          expect(Spree.user_class.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 2
        end
      end
    end

    context 'searching by name' do
      let!(:customer) { create(:user_with_addreses) }

      context 'by first_name' do
        let(:name) { customer.bill_address.firstname }
        let(:emails) { [] }
        let(:phones) { [] }


        it 'return single result' do
          result = subject.execute
          expect(result.size).to eq 1
          expect(result.first.ship_address.full_name).to eq customer.ship_address.full_name
        end
      end

      context 'by last_name' do
        let(:name) { customer.bill_address.lastname }
        let(:emails) { [] }
        let(:phones) { [] }

        it 'return single result' do
          result = subject.execute
          expect(result.size).to eq 1
          expect(result.first.ship_address.full_name).to eq customer.ship_address.full_name
        end
      end

      context 'uppercase name' do
        let(:name) { customer.bill_address.full_name.upcase }
        let(:emails) { [] }
        let(:phones) { [] }

        it 'return single result' do
          result = subject.execute
          expect(result.size).to eq 1
          expect(result.first.ship_address.full_name).to eq customer.ship_address.full_name
        end
      end

      context 'lowercase name' do
        let(:name) { customer.bill_address.full_name.downcase }
        let(:emails) { [] }
        let(:phones) { [] }

        it 'return single result' do
          result = subject.execute
          expect(result.size).to eq 1
          expect(result.first.ship_address.full_name).to eq customer.ship_address.full_name
        end
      end
    end

    context 'searching by phone_numbers' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:other_customer) { create(:user_with_addreses) }

      context 'with single phone number' do
        let(:name) { '' }
        let(:emails) { [] }
        let(:phones) { [customer.bill_address.phone] }

        # before { other_customer.bill_address.update(phone: '777-777-777') }

        xit 'return single result' do
          expect(Spree.user_class.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 1
        end
      end

      context 'with multiple phone number' do
        let(:name) { '' }
        let(:emails) { [] }
        let(:phones) { [customer.ship_address.phone, other_customer.ship_address.phone] }

        it 'return multiple result' do
          expect(Spree.user_class.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 2
        end
      end
    end
  end
end