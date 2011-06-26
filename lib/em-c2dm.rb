require "eventmachine"
require "em-http-request"
require "logger"
require "uuid"
require "em-c2dm/client"
require "em-c2dm/notification"

$uuid = UUID.new

module EventMachine
  module C2DM
    class << self
      def push(registation_id, options = {})
        notification = EM::C2DM::Notification.new(registation_id, options)
        @client ||= Client.new
        @client.deliver(notification)
      end

      def store
        @store
      end
      
      def store=(store)
        @store = store
      end
      
      def token=(token)
        store.set(token)
        @token = token
      end
      
      def token
        @token ||= store.get
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