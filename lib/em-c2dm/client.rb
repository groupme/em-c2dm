require "em-c2dm/response"
require "em-c2dm/log_message"

module EventMachine
  module C2DM
    class Client
      URL = "https://android.apis.google.com/c2dm/send"

      def initialize(notification)
        @notification = notification
      end

      def deliver(block = nil)
        verify_token
        @start = Time.now.to_f

        http = EventMachine::HttpRequest.new(URL).post(
          :query  => @notification.params,
          :head   => @notification.headers
        )

        http.callback do
          response = Response.new(http, @start)
          LogMessage.new(@notification, response).log
          EM::C2DM.token = response.client_auth if response.client_auth
          block.call(response) if block
        end

        http.errback do |e|
          error(e.inspect)
        end
      end

      private

      def verify_token
        raise "token not set!" unless EM::C2DM.token
      end
    end
  end
end
