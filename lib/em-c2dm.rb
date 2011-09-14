require "eventmachine"
require "em-http-request"
require "logger"
require "uuid"
require "em-c2dm/auth"
require "em-c2dm/client"
require "em-c2dm/response"
require "em-c2dm/notification"

$uuid = UUID.new

module EventMachine
  module C2DM
    class << self
      def authenticate(username, password)
        Auth.authenticate(username, password)
      end

      def push(registation_id, options, &block)
        notification = Notification.new(registation_id, options)
        Client.new(notification).deliver(block)
      end

      def token=(token)
        logger.info("setting new auth token")
        @token = token
      end

      def token
        @token
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      def logger=(new_logger)
        @logger = new_logger
      end
    end
  end
end
