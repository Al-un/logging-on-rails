# frozen_string_literal: true

# https://github.com/freeformz/logglier
Rails.application.configure do
  # Display offline warning
  logger_config = ENV['LOGGER_CONFIG']
  if ['LOGGLY', 'FINAL'].include?(logger_config)
    # Environment dependent tagging
    loggy_url = 'https://logs-01.loggly.com/inputs/' + ENV['LOGGLY_TOKEN'] +
                '/tag/logging-on-rails,rails,' + Rails.env
    puts `=== Loggly is enabled for URL #{loggy_url}`
    # Always send in JSON format.
    # [TODO] check if input has to be in Hash
    loggly = Logglier.new(loggy_url, threaded: true, format: :json)
    # Append logger
    Rails.logger.extend(ActiveSupport::Logger.broadcast(loggly))
  end
end
