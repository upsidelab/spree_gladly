# frozen_string_literal: true

require 'spec_helper'

describe Auth::RequestNormalizer do
  subject { described_class.new(headers).normalize(request) }

  describe '#normalize' do
    context 'given extra headers' do
      let(:request) do
        test_request(
          'GET',
          '/',
          { 'a' => 'value/a', 'b' => 'value/b', 'c' => 'value/c', 'd' => 'value/d' },
          'body'
        )
      end

      let(:headers) { %w[a b d] }

      let(:normalized_request) do
        <<~NORMALIZED.chomp
          GET
          /

          a:value/a
          b:value/b
          d:value/d

          a;b;d
          230d8358dc8e8890b4c58deeb62912ee2f20357ae92a5cc861b98e68fe31acb5
        NORMALIZED
      end

      it { is_expected.to eq(normalized_request) }
    end

    context 'given gladly documentation example' do
      let(:request) do
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
          # rubocop:disable Layout/LineLength
          '{"lookupLevel":"DETAILED","query":{"emails":["martha.williams@gmail.com"],"externalCustomerId":"abc","favoriteDate":"2018-08-19T07:00:00.000Z","favoriteFood":"Apple Pie","id":"o2sg-TMTSD2rTwMuxzewbA","name":"Martha Williams","phones":["+15013299800"]},"uniqueMatchRequired":true}'
          # rubocop:enable Layout/LineLength
        )
      end

      let(:headers) { %w[accept content-type gladly-correlation-id gladly-time x-b3-traceid] }

      let(:normalized_request) do
        <<~NORMALIZED.chomp
          POST
          /api/v2/customer/lookup

          accept:application/json
          content-type:application/json
          gladly-correlation-id:vXmSEPjVSWCaCMzvjufxZg
          gladly-time:20190213T214016Z
          x-b3-traceid:bd799210f8d549609a08ccef8ee7f166

          accept;content-type;gladly-correlation-id;gladly-time;x-b3-traceid
          f187462a1d8e09bc86ea4b4ff8c022e5e4ed23ae783b3b1b5baee4b8d69e02ca
        NORMALIZED
      end

      it { is_expected.to eq(normalized_request) }

      it 'have a correct sha256 hash' do
        expect(OpenSSL::Digest.new('sha256').hexdigest(subject))
          .to eq('f96c13077adb3c06df1fa5fda8a6f32d7067735f63aa58d47e45fd6429d3cad3')
      end
    end
  end
end
