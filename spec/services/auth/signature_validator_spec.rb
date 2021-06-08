# frozen_string_literal: true

require 'spec_helper'

describe Auth::SignatureValidator do
  let(:threshold) { nil }

  subject { described_class.new(api_key, threshold).validate(request) }

  describe '#validate' do
    context 'given an unset signing key' do
      let(:request) { 'whatever' }
      let(:api_key) { nil }

      it 'raise an error' do
        expect { subject }.to raise_error(Auth::MissingKeyError)
      end
    end

    context 'given no Gladly-Authorization header' do
      let(:request) do
        # rubocop:disable Layout/LineLength
        test_request(
          'POST',
          '/api/v2/customer/lookup',
          {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Gladly-Correlation-Id' => 'vXmSEPjVSWCaCMzvjufxZg',
            'X-B3-Traceid' => 'bd799210f8d549609a08ccef8ee7f166',
            'Gladly-Time' => '20190213T214016Z'
          },
          '{"lookupLevel":"DETAILED","query":{"emails":["martha.williams@gmail.com"],"externalCustomerId":"abc","favoriteDate":"2018-08-19T07:00:00.000Z","favoriteFood":"Apple Pie","id":"o2sg-TMTSD2rTwMuxzewbA","name":"Martha Williams","phones":["+15013299800"]},"uniqueMatchRequired":true}'
        )
        # rubocop:enable Layout/LineLength
      end

      let(:api_key) { 'test-apikey-1' }

      it 'raise an error' do
        expect { subject }.to raise_error(Auth::HeaderParseError)
      end
    end

    context 'given no Gladly-Time header' do
      let(:request) do
        # rubocop:disable Layout/LineLength
        test_request(
          'POST',
          '/api/v2/customer/lookup',
          {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Gladly-Correlation-Id' => 'vXmSEPjVSWCaCMzvjufxZg',
            'X-B3-Traceid' => 'bd799210f8d549609a08ccef8ee7f166',
            'Gladly-Authorization' => 'SigningAlgorithm=hmac-sha256, SignedHeaders=accept;content-type;gladly-correlation-id;gladly-time;x-b3-traceid, Signature=4c633fca4914f51df04c9ec40f4545d66d653e771c6634e33eed52a242bc278c'
          },
          '{"lookupLevel":"DETAILED","query":{"emails":["martha.williams@gmail.com"],"externalCustomerId":"abc","favoriteDate":"2018-08-19T07:00:00.000Z","favoriteFood":"Apple Pie","id":"o2sg-TMTSD2rTwMuxzewbA","name":"Martha Williams","phones":["+15013299800"]},"uniqueMatchRequired":true}'
        )
        # rubocop:enable Layout/LineLength
      end

      let(:api_key) { 'test-apikey-1' }

      it 'raise an error' do
        expect { subject }.to raise_error(Auth::HeaderParseError)
      end
    end

    context 'given gladly documentation example' do
      let(:request) do
        # rubocop:disable Layout/LineLength
        test_request(
          'POST',
          '/api/v2/customer/lookup',
          {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Gladly-Correlation-Id' => 'vXmSEPjVSWCaCMzvjufxZg',
            'X-B3-Traceid' => 'bd799210f8d549609a08ccef8ee7f166',
            'Gladly-Time' => '20190213T214016Z',
            'Gladly-Authorization' => 'SigningAlgorithm=hmac-sha256, SignedHeaders=accept;content-type;gladly-correlation-id;gladly-time;x-b3-traceid, Signature=4c633fca4914f51df04c9ec40f4545d66d653e771c6634e33eed52a242bc278c'
          },
          '{"lookupLevel":"DETAILED","query":{"emails":["martha.williams@gmail.com"],"externalCustomerId":"abc","favoriteDate":"2018-08-19T07:00:00.000Z","favoriteFood":"Apple Pie","id":"o2sg-TMTSD2rTwMuxzewbA","name":"Martha Williams","phones":["+15013299800"]},"uniqueMatchRequired":true}'
        )
        # rubocop:enable Layout/LineLength
      end

      context 'given a valid key' do
        let(:api_key) { 'test-apikey-1' }

        it { is_expected.to be_truthy }
      end

      context 'given a valid key and old signature' do
        let(:api_key) { 'test-apikey-1' }
        let(:threshold) { 1.minute }

        it 'raise an error' do
          t = Time.new(2019, 2, 13, 21, 42, 16, '+00:00') # 2 minutes after

          expect { Timecop.freeze(t) { subject } }.to raise_error(Auth::InvalidSignatureError)
        end
      end

      context 'given a valid key and new signature' do
        let(:api_key) { 'test-apikey-1' }
        let(:threshold) { 5.minutes }

        it 'return true' do
          t = Time.new(2019, 2, 13, 21, 43, 16, '+00:00') # 3 minutes after

          expect(Timecop.freeze(t) { subject }).to be_truthy
        end
      end

      context 'given an invalid key' do
        let(:api_key) { 'test-apikey-2' }

        it 'raise an error' do
          expect { subject }.to raise_error(Auth::InvalidSignatureError)
        end
      end
    end
  end
end
