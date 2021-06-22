# frozen_string_literal: true

class LookupValidator
  def call(params)
    errors = []

    errors += validate_lookup_level(params)
    errors += validate_unique_match_required(params)
    errors += validate_query_emails(params)
    errors += validate_query_phones(params)
    errors += validate_query_name(params)
    errors += validate_query_external_customer_id(params)

    ValidationResult.new(errors)
  end

  private

  def validate_lookup_level(params)
    lookup_level = params[:lookupLevel]

    return [%i[lookupLevel missing]] if lookup_level.nil?
    return [%i[lookupLevel invalid]] unless lookup_level =~ /\A(?:basic|detailed)\Z/i

    []
  end

  def validate_unique_match_required(params)
    unique_match_required = params[:uniqueMatchRequired]

    return [%i[uniqueMatchRequired missing]] if unique_match_required.nil?

    if detailed_lookup?(params)
      return [%i[uniqueMatchRequired not_true]] unless unique_match_required.in?([true, 'true'])
    else
      return [%i[uniqueMatchRequired invalid]] unless unique_match_required.in?([true, false, 'true', 'false'])
    end

    []
  end

  def validate_query_emails(params)
    emails = params.dig(:query, :emails)

    return [] if emails.nil? || string_or_array_of_strings?(emails)

    [%i[query_emails invalid]]
  end

  def validate_query_phones(params)
    phones = params.dig(:query, :phones)

    return [] if phones.nil? || string_or_array_of_strings?(phones)

    [%i[query_phones invalid]]
  end

  def validate_query_name(params)
    name = params.dig(:query, :name)

    return [] if name.nil? || nonempty_string?(name)

    [%i[query_name invalid]]
  end

  def validate_query_external_customer_id(params)
    id = params.dig(:query, :externalCustomerId)

    return [%i[query_externalCustomerId missing]] if detailed_lookup?(params) && id.nil?
    return [%i[query_externalCustomerId invalid]] if id.present? && !nonempty_string?(id)

    []
  end

  def detailed_lookup?(params)
    params[:lookupLevel] =~ /\Adetailed\Z/i
  end

  def nonempty_string?(value)
    value.is_a?(String) && !value.empty?
  end

  def string_or_array_of_strings?(value)
    return true if nonempty_string?(value)
    return true if value.is_a?(Array) && value.all? { |v| nonempty_string?(v) }

    false
  end
end
