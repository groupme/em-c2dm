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
          :head   => headers
        )

        http.callback do
          response = Response.new(http)
          log(response)

          if response.client_auth
            EM::C2DM.token = response.client_auth
          end

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

      def headers
        {
          "Authorization"   => "GoogleLogin auth=#{EM::C2DM.token}",
          "Content-Length"  => 0,
          "User-Agent"      => "em-c2dm #{EM::C2DM::VERSION}"
        }
      end

      def elapsed
        ((Time.now.to_f - @start) * 1000.0).round # in milliseconds
      end

      def log(message)
        EM::C2DM.logger.info(log_wrapper(message))
      end

      def error(message)
        EM::C2DM.logger.error(log_wrapper(message))
      end

      def log_wrapper(message)
        "#{message} uuid=#{@notification.uuid} time=#{elapsed}ms"
      end
    end
  end
end
