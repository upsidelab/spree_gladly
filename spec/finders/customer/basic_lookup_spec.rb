require 'spec_helper'

describe Customer::BasicLookup do
  subject { described_class.new(params: params) }

  describe '#execute' do
    context 'with invalid query params' do
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

    context 'searching by all params' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:other_customer) { create(:user_with_addreses) }
      let(:params) do
        {
          query: {
            emails: customer.email,
            phones: [other_customer.ship_address.phone],
            name: customer.ship_address.full_name
          }
        }
      end

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
        let(:params) do
          {
            query: {
              emails: customer.email
            }
          }
        end

        it 'return single result' do
          expect(Spree.user_class.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 1
        end
      end

      context 'with multiple email addresses' do
        let(:params) do
          {
            query: {
              emails: "#{customer.email}, #{other_customer.email}"
            }
          }
        end

        it 'return multiple result' do
          expect(Spree.user_class.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 2
        end
      end
    end

    context 'searching by name' do
      let!(:customer) { create(:user_with_addreses) }
      let(:params) do
        {
          query: {
            name: customer.ship_address.full_name
          }
        }
      end
      it 'return single result' do
        result = subject.execute
        expect(result.size).to eq 1
        expect(result.first.ship_address.full_name).to eq customer.ship_address.full_name
      end
    end

    context 'searching by phone_numbers' do
      let!(:customer) { create(:user_with_addreses) }
      let!(:other_customer) { create(:user_with_addreses) }

      context 'with single phone number' do
        let(:params) do
          {
            query: {
              phones: [customer.ship_address.phone]
            }
          }
        end

        before { other_customer.ship_address.update(phone: '666-666-666') }

        it 'return single result' do
          expect(Spree.user_class.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 1
        end
      end

      context 'with multiple phone number' do
        let(:params) do
          {
            query: {
              phones: [customer.ship_address.phone, other_customer.ship_address.phone]
            }
          }
        end

        it 'return multiple result' do
          expect(Spree.user_class.all.size).to eq 2
          result = subject.execute
          expect(result.size).to eq 2
        end
      end
    end
  end
end
