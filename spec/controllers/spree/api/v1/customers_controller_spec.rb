require 'spec_helper'

describe ::Spree::Api::V1::CustomersController, type: :request do

  describe '#lookup' do
    let!(:address) { create(:address) }
    let!(:user) { create(:user, ship_address: address, bill_address: address) }

    context 'basic lookup' do
      context 'with valid params' do
        let(:params) do
          {
            lookupLevel: 'BASIC',
            query: {
              emails: [user.email],
              phones: [user.ship_address.phone],
              name: user.ship_address.full_name
            }
          }.as_json
        end

        before { post '/api/v1/customers/lookup', params: params }

        it 'return HTTP 200' do
          expect(response.status).to eq 200
        end

        it 'return expected results' do
          expect(JSON.parse(response.body)['data'][0]['attributes'].keys).to eq %w[email name phone]
        end
      end
    end

    context 'detailed lookup' do
      context 'with valid params' do
        let(:params) do
          {
            lookupLevel: 'DETAILED',
            query: {
              emails: [user.email],
              phones: [user.ship_address.phone],
              name: user.ship_address.full_name
            }
          }.as_json
        end
        let!(:order) { create(:completed_order_with_pending_payment, user: user) }

        before { post '/api/v1/customers/lookup', params: params }

        it 'return HTTP 200' do
          expect(response.status).to eq 200
        end

        it 'return expected results' do
          results = JSON.parse(response.body)

          expect(results['data'][0]['attributes']['customer']).not_to be_empty
          expect(results['data'][0]['attributes']['line_items']).not_to be_empty
          expect(results['data'][0]['attributes']['shipments']).not_to be_empty
          expect(results['data'][0]['attributes']['payments']).to eq nil
        end
      end
    end
  end
end
