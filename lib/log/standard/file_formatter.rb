# frozen_string_literal: true

module Log
  module Standard
    # Formatting JSON formatting for file logging
    class FileFormatter < ::Logger::Formatter
      def call(severity, timestamp, progname, msg)
        # https://stackoverflow.com/a/29855485/4906586
        # timestamp.to_f => otherwise accuracy is limited to seconds only
        {
          pid: $$,
          timestamp: timestamp.to_f,
          formatted_time: timestamp.strftime("%Y-%m-%d %H:%M:%S.%L"),
          severity: severity,
          progname: progname,
          msg: msg
        }.to_json.to_s + "\n"
      end
    end
  end
end
