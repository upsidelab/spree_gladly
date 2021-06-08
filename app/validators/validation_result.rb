# frozen_string_literal: true

class ValidationResult
  attr_reader :errors

  def initialize(errors)
    @errors = errors
  end

  def success?
    errors.empty?
  end

  def format_errors
    @errors.map do |error|
      attr, code = error

      {
        attr: attr.to_s,
        code: code.to_s,
        detail: Spree.t("spree_gladly.errors.#{attr}.#{code}")
      }
    end
  end
end
