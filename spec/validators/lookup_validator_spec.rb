# frozen_string_literal: true

require 'spec_helper'

describe LookupValidator do
  subject { described_class.new.call(params) }

  let(:lookup_level) { 'BASIC' }
  let(:unique_match_required) { false }
  let(:phones) { nil }
  let(:emails) { nil }
  let(:name) { nil }
  let(:external_customer_id) { nil }

  let(:params) do
    {
      lookupLevel: lookup_level,
      uniqueMatchRequired: unique_match_required,
      query: {
        phones: phones,
        emails: emails,
        name: name,
        externalCustomerId: external_customer_id
      }.compact
    }.compact
  end

  shared_examples 'valid' do
    it 'valid' do
      expect(subject.errors).to be_empty
    end
  end

  shared_examples 'invalid' do |errors|
    it 'invalid' do
      res = subject
      expect(res.errors).not_to be_empty
      errors.each { |error| expect(res.errors).to include(error) }
    end
  end

  context 'missing lookup level' do
    let(:lookup_level) { nil }

    include_examples 'invalid', [%i[lookupLevel missing]]
  end

  context 'invalid lookup level' do
    let(:lookup_level) { 'FANCY' }

    include_examples 'invalid', [%i[lookupLevel invalid]]
  end

  context 'basic lookup level' do
    let(:lookup_level) { 'BASIC' }

    include_examples 'valid'

    context 'false uniqueMatchRequired' do
      let(:unique_match_required) { false }

      include_examples 'valid'
    end

    context 'missing externalCustomerId' do
      let(:external_customer_id) { nil }

      include_examples 'valid'
    end
  end

  context 'detailed lookup level' do
    let(:lookup_level) { 'DETAILED' }
    let(:unique_match_required) { true }
    let(:external_customer_id) { '123' }

    include_examples 'valid'

    context 'false uniqueMatchRequired' do
      let(:unique_match_required) { false }

      include_examples 'invalid', [%i[uniqueMatchRequired not_true]]
    end

    context 'missing externalCustomerId' do
      let(:external_customer_id) { nil }

      include_examples 'invalid', [%i[query_externalCustomerId missing]]
    end

    context 'invalid externalCustomerId' do
      let(:external_customer_id) { 123 }

      include_examples 'invalid', [%i[query_externalCustomerId invalid]]
    end
  end

  context 'given valid emails' do
    context 'string' do
      let(:emails) { "email" }

      include_examples 'valid'
    end

    context 'array of strings' do
      let(:emails) { %w[foo bar baz] }

      include_examples 'valid'
    end
  end

  context 'given invalid emails' do
    context 'empty string' do
      let(:emails) { '' }

      include_examples 'invalid', [%i[query_emails invalid]]
    end

    context 'integer' do
      let(:emails) { 123 }

      include_examples 'invalid', [%i[query_emails invalid]]
    end

    context 'invalid array 1' do
      let(:emails) { ['foo', ''] }

      include_examples 'invalid', [%i[query_emails invalid]]
    end

    context 'invalid array 2' do
      let(:emails) { ['bar', 5] }

      include_examples 'invalid', [%i[query_emails invalid]]
    end
  end

  context 'given valid phones' do
    context 'string' do
      let(:phones) { "phone" }

      include_examples 'valid'
    end

    context 'array of strings' do
      let(:phones) { %w[foo bar baz] }

      include_examples 'valid'
    end
  end

  context 'given invalid phones' do
    context 'empty string' do
      let(:phones) { '' }

      include_examples 'invalid', [%i[query_phones invalid]]
    end

    context 'integer' do
      let(:phones) { 123 }

      include_examples 'invalid', [%i[query_phones invalid]]
    end

    context 'invalid array 1' do
      let(:phones) { ['foo', ''] }

      include_examples 'invalid', [%i[query_phones invalid]]
    end

    context 'invalid array 2' do
      let(:phones) { ['bar', 5] }

      include_examples 'invalid', [%i[query_phones invalid]]
    end
  end

  context 'given valid name' do
    context 'absent' do
      let(:name) { nil }

      include_examples 'valid'
    end

    context 'string' do
      let(:name) { 'James Bond' }

      include_examples 'valid'
    end
  end

  context 'given invalid name' do
    context 'empty string' do
      let(:name) { '' }

      include_examples 'invalid', [%i[query_name invalid]]
    end

    context 'integer' do
      let(:name) { 7 }

      include_examples 'invalid', [%i[query_name invalid]]
    end
  end
end
