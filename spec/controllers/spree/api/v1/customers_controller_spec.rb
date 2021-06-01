require 'spec_helper'

describe ::Spree::Api::V1::CustomersController, type: :request do
  describe '#lookup' do
    let!(:address) { create(:address) }
    let!(:user) { create(:user, ship_address: address, bill_address: address) }

    context 'signature validation' do
      # rubocop:disable Layout/LineLength
      let(:body) do
        '{"lookupLevel":"DETAILED","query":{"emails":["martha.williams@gmail.com"],"externalCustomerId":"abc","favoriteDate":"2018-08-19T07:00:00.000Z","favoriteFood":"Apple Pie","id":"o2sg-TMTSD2rTwMuxzewbA","name":"Martha Williams","phones":["+15013299800"]},"uniqueMatchRequired":true}'
      end
      let(:headers) do
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Gladly-Correlation-Id' => 'vXmSEPjVSWCaCMzvjufxZg',
          'X-B3-Traceid' => 'bd799210f8d549609a08ccef8ee7f166',
          'Gladly-Time' => '20190213T214016Z',
          'Gladly-Authorization' => 'SigningAlgorithm=hmac-sha256, SignedHeaders=accept;content-type;gladly-correlation-id;gladly-time;x-b3-traceid, Signature=38f2a59caaddcab2c738ff75866287f43ec8a9c0a2171ef15bbe6a04b6029f94'
        }
      end
      # rubocop:enable Layout/LineLength

      before do
        SpreeGladly.signing_key = signing_key
        SpreeGladly.signing_threshold = signing_threshold
        Timecop.freeze(Time.new(2019, 2, 13, 21, 42, 16, '+00:00'))

        post '/api/v1/customers/lookup', params: body, headers: headers
      end

      after do
        SpreeGladly.signing_key = nil
        SpreeGladly.signing_threshold = nil
        Timecop.return
      end

      context 'given a valid signature' do
        let(:signing_key) { 'test-apikey-1' }
        let(:signing_threshold) { 5.minutes }

        it 'return HTTP 200' do
          expect(response.status).to eq 200
        end
      end

      context 'given an invalid signature' do
        let(:signing_key) { 'test-apikey-different' }
        let(:signing_threshold) { 5.minutes }

        it 'return HTTP 401' do
          expect(response.status).to eq 401
        end

        it 'return expected errors' do
          errors = JSON.parse(response.body).fetch('errors', [])
          expect(errors.size).to eq 1
          expect(errors.first['attr']).to eq 'Gladly-Authorization'
          expect(errors.first['code']).to eq 'Auth::InvalidSignatureError'
          expect(errors.first['detail']).to eq 'Signature is incorrect'
        end
      end

      context 'given an old signature' do
        let(:signing_key) { 'test-apikey-1' }
        let(:signing_threshold) { 1.minute }

        it 'return HTTP 401' do
          expect(response.status).to eq 401
        end

        it 'return expected errors' do
          errors = JSON.parse(response.body).fetch('errors', [])
          expect(errors.size).to eq 1
          expect(errors.first['attr']).to eq 'Gladly-Authorization'
          expect(errors.first['code']).to eq 'Auth::InvalidSignatureError'
          expect(errors.first['detail']).to eq 'Signature is too old'
        end
      end
    end

    context 'basic lookup' do
      context 'given valid params' do
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
      context 'given valid params' do
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
