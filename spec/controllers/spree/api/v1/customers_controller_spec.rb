require 'spec_helper'

describe ::Spree::Api::V1::CustomersController, type: :request do
  describe '#lookup' do
    let!(:address) { create(:address) }
    let!(:user) { create(:user, ship_address: address, bill_address: address) }

    context 'signature validation' do
      # rubocop:disable Layout/LineLength
      let(:body) do
        '{"lookupLevel":"DETAILED","query":{"emails":"martha.williams@gmail.com","externalCustomerId":"1","favoriteDate":"2018-08-19T07:00:00.000Z","favoriteFood":"Apple Pie","id":"o2sg-TMTSD2rTwMuxzewbA","name":"Martha Williams","phones":["+15013299800"]},"uniqueMatchRequired":true}'
      end
      let(:headers) do
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Gladly-Correlation-Id' => 'vXmSEPjVSWCaCMzvjufxZg',
          'X-B3-Traceid' => 'bd799210f8d549609a08ccef8ee7f166',
          'Gladly-Time' => '20190213T214016Z',
          'Gladly-Authorization' => 'SigningAlgorithm=hmac-sha256, SignedHeaders=accept;content-type;gladly-correlation-id;gladly-time;x-b3-traceid, Signature=36dda3cf891e30523efd4670dbec8760a11140956953a01163643d908d3d888d'
        }
      end
      # rubocop:enable Layout/LineLength

      before do
        SpreeGladly::Config.signing_key = signing_key
        SpreeGladly::Config.signing_threshold = signing_threshold
        Timecop.freeze(Time.new(2019, 2, 13, 21, 42, 16, '+00:00'))

        post '/api/v1/customers/lookup', params: body, headers: headers
      end

      after do
        SpreeGladly::Config.signing_key = nil
        SpreeGladly::Config.signing_threshold = nil
        Timecop.return
      end

      context 'given a valid signature' do
        let(:signing_key) { 'test-apikey-1' }
        let(:signing_threshold) { 5.minutes }

        xit 'return HTTP 200' do
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
      before { stub_signature_validator }

      context 'given valid params' do
        let(:params) do
          {
            lookupLevel: 'BASIC',
            query: {
              emails: user.email,
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
          results = JSON.parse(response.body)

          expect(results['results']&.size).to eq 1
          expect(results['results'].first.keys.sort).to eq %w[externalCustomerId name email phone].sort
          expect(results['results'].first['externalCustomerId']).to eq user.id.to_s
          expect(results['results'].first['name']).to eq user.ship_address.full_name
          expect(results['results'].first['email']).to eq user.email
          expect(results['results'].first['phone']).to eq user.ship_address.phone
        end
      end
    end

    context 'detailed lookup' do
      before { stub_signature_validator }

      context 'given valid params' do
        let(:params) do
          {
            lookupLevel: 'DETAILED',
            query: {
              emails: user.email,
              externalCustomerId: user.id.to_s
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

          expect(results['results']&.size).to eq 1
          expect(results['results'].first.keys.sort)
            .to eq %w[externalCustomerId name address emails phones transactions].sort
          expect(results['results'].first['externalCustomerId']).to eq user.id.to_s
          expect(results['results'].first['name']).to eq user.ship_address.full_name
          expect(results['results'].first['emails']).not_to be_empty
          expect(results['results'].first['phones']).not_to be_empty
          expect(results['results'].first['transactions']).not_to be_empty
        end
      end
    end

    def stub_signature_validator
      signature_validator = double('SignatureValidator', { validate: true })
      allow(Auth::SignatureValidator).to receive(:new).and_return(signature_validator)
    end
  end
end
