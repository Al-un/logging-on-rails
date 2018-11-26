# frozen_string_literal: true

module Log
  module Ougai
    # Extends Ougai logger for rails logging
    class Logger < ::Ougai::Logger
      include ActiveSupport::LoggerThreadSafeLevel
      include LoggerSilence

      def initialize(*args)
        super
        after_initialize if respond_to? :after_initialize
      end
    end
  end
end
