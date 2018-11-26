class ApplicationController < ActionController::Base 
  # append_info_to_payload is a method specific to Lograge. It is 
  # meant to add additional information to log payload. However,
  # adding here is not enough: it has to be parametered in lograge
  # configuration file
  def append_info_to_payload(payload)
    super
    # adding remote ip address
    payload[:remote_ip] = request.remote_ip
  end
end
