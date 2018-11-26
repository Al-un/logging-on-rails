# frozen_string_literal: true

module Log
  module Standard
    # Console logger with console custom format
    class ConsoleLogger < ActiveSupport::Logger
      # Override initialize from
      # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/logger.rb
      def initialize(*args)
        super(*args)
        # Override formatter but leave it opened to overriding
        @formatter = Log::Standard::ConsoleFormatter.new
      end
    end
  end
end
