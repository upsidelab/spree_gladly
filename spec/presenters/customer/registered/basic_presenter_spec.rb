# frozen_string_literal: true

require 'spec_helper'

describe Customer::Registered::BasicPresenter, as: :presenter do
  subject { described_class.new(resource: resource) }

  describe '#to_h' do
    context 'with given resources' do
      let!(:resource) { create_list(:completed_order_with_pending_payment, 4) }

      it 'return formatted results' do
        results = subject.to_h
        expect(results.size).to eq 4
        expect(results.first.keys).to eq %i[externalCustomerId spreeId address name emails phones]
      end
    end

    context 'with given empty resources' do
      let(:resource) { [] }

      it 'return empty hash' do
        result = subject.to_h

        expect(result.is_a?(Array)).to eq true
        expect(result.empty?).to eq true
      end
    end
  end
end