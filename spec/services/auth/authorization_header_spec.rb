# frozen_string_literal: true

require 'spec_helper'

describe Auth::AuthorizationHeader do
  subject { described_class.new(header) }

  describe '.new' do
    context 'given signature headers of invalid format' do
      it 'raise an error' do
        expect { described_class.new(nil) }.to raise_error(Auth::HeaderParseError)
        expect { described_class.new('') }.to raise_error(Auth::HeaderParseError)
        expect { described_class.new('invalid') }.to raise_error(Auth::HeaderParseError)
        expect { described_class.new('foo=bar') }.to raise_error(Auth::HeaderParseError)
      end
    end

    context 'given invalid signing algorithm values' do
      let(:header) { build_header('invalid', 'header', '1234') }

      it 'raise an error' do
        expect { subject }.to raise_error(Auth::HeaderParseError)
      end
    end

    context 'given no headers' do
      let(:header) { build_header('md5', '', '1234') }

      it 'raise an error' do
        expect { subject }.to raise_error(Auth::HeaderParseError)
      end
    end

    context 'given unsorted headers' do
      let(:header) { build_header('md5', 'b;a', '1234') }

      it 'raise an error' do
        expect { subject }.to raise_error(Auth::HeaderParseError)
      end
    end

    context 'given valid parameters' do
      let(:header) { build_header('md5', 'a;b;c', '1234') }

      it 'return a valid AuthorizationHeader' do
        expect(subject.signing_algorithm_name).to eq('md5')
        expect(subject.signing_algorithm).to eq(OpenSSL::Digest.new('MD5'))
        expect(subject.signed_headers).to eq(%w[a b c])
        expect(subject.signature).to eq('1234')
      end
    end

    context 'given gladly documentation example' do
      let(:header) do
        'SigningAlgorithm=hmac-sha256, '\
        'SignedHeaders=accept;content-type;gladly-correlation-id;gladly-time;x-b3-traceid, '\
        'Signature=4c633fca4914f51df04c9ec40f4545d66d653e771c6634e33eed52a242bc278c'
      end

      it 'return a valid AuthorizationHeader' do
        expect(subject.signing_algorithm_name).to eq('hmac-sha256')
        expect(subject.signing_algorithm).to eq(OpenSSL::Digest.new('SHA256'))
        expect(subject.signed_headers).to eq(%w[accept content-type gladly-correlation-id gladly-time x-b3-traceid])
        expect(subject.signature).to eq('4c633fca4914f51df04c9ec40f4545d66d653e771c6634e33eed52a242bc278c')
      end
    end
  end

  def build_header(signing_algorithm, signed_headers, signature)
    "SigningAlgorithm=#{signing_algorithm}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
  end
end
