# frozen_string_literal: true

require 'spec_helper'

describe Auth::TimeHeader do
  subject { described_class.new(time_header) }

  describe '.new' do
    context 'given invalid padding' do
      let(:time_header) { '20190213T214016Z ' }

      it 'raise an error' do
        expect { subject }.to raise_error(Auth::HeaderParseError)
      end
    end

    context 'given an invalid date format' do
      let(:time_header) { '637079415318000' }

      it 'raise an error' do
        expect { subject }.to raise_error(Auth::HeaderParseError)
      end
    end

    context 'given a valid header' do
      let(:time_header) { '20190213T214016Z' }

      it 'set correct timestamp, date and time' do
        expect(subject.timestamp).to eq('20190213T214016Z')
        expect(subject.date).to eq('20190213')
        expect(subject.time).to eq(Time.new(2019, 2, 13, 21, 40, 16, '+00:00'))
      end
    end
  end
end
