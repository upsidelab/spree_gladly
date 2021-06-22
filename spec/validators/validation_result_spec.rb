# frozen_string_literal: true

require 'spec_helper'

describe ValidationResult do
  let(:subject) { described_class.new(errors) }

  context('#format_errors') do
    let(:errors) { [] }

    context 'given no errors' do
      it 'return empty array' do
        expect(subject.format_errors).to eq []
      end
    end

    context 'given errors' do
      let(:errors) do
        [
          %i[lookupLevel missing],
          %i[lookupLevel invalid],
          %i[uniqueMatchRequired not_true],
          %i[query_emails invalid],
          %i[query_phones invalid],
          %i[query_externalCustomerId missing]
        ]
      end

      it 'return empty array' do
        expected = [
          { attr: 'lookupLevel', code: 'missing', detail: 'lookupLevel must be present' },
          { attr: 'lookupLevel', code: 'invalid', detail: 'lookupLevel must be BASIC or DETAILED' },
          { attr: 'uniqueMatchRequired', code: 'not_true',
            detail: 'uniqueMatchRequired must be true for Detailed Lookup' },
          { attr: 'query_emails', code: 'invalid',
            detail: 'query emails must be a nonempty string or an array of nonempty strings' },
          { attr: 'query_phones', code: 'invalid',
            detail: 'query phones must be a nonempty string or an array of nonempty strings' },
          { attr: 'query_externalCustomerId', code: 'missing',
            detail: 'query externalCustomerId must be present for Detailed Lookup' }
        ]

        expect(subject.format_errors).to eq expected
      end
    end
  end
end
