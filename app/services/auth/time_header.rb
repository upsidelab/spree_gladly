# frozen_string_literal: true

module Auth
  class TimeHeader
    TIME_HEADER_FORMAT = /\A(\d{8})T\d{6}Z\Z/.freeze
    TIME_STRPTIME_FORMAT = '%Y%m%dT%H%M%SZ%Z'

    attr_reader :timestamp, :date, :time

    def initialize(header)
      match = TIME_HEADER_FORMAT.match(header)
      raise HeaderParseError, 'Unsupported Gladly-Time header format' if match.nil?

      @timestamp = match[0]
      @date = match[1]
      @time = Time.strptime(utc_timestamp, TIME_STRPTIME_FORMAT)
    end

    private

    def utc_timestamp
      "#{@timestamp}+0000"
    end
  end
end
