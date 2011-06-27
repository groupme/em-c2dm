module EventMachine
  module C2DM
    class Client
      URL = "https://android.apis.google.com/c2dm/send"

      def deliver(notification)
        @start = Time.now.to_f
        @notification = notification
        raise "auth token not set" unless EM::C2DM.token
        @http = EventMachine::HttpRequest.new(URL).post(
          :query  => @notification.params,
          :head   => {
            "Authorization"   => "GoogleLogin auth=#{EM::C2DM.token}",
            "Content-Length"  => 0,
            "User-Agent"      => "em-c2dm #{EM::C2DM::VERSION}"
          }
        )
        @http.callback  { on_complete }
        @http.errback   { |x| log_error("unknown error: #{x.inspect}") }
      end

      private

      def on_complete
        update_token

        code = @http.response_header.status.to_i
        if code == 200
          EM::C2DM.logger.info("#{@notification.uuid} success (#{elapsed}ms)")
        else
          EM::C2DM.logger.error("#{@notification.uuid} error: #{@http.response_header} #{@http.response.inspect}")
          on_failure(code)
        end
      end

      def on_failure(code)
        case code
        when 401
          log_error("invalid auth token")
        when 502, 503
          log_error("service unavilable")
          retry_after = @http.response_header["Retry-After"]

          unless retry_after.nil? || retry_after.empty?
            log_error("retrying after #{retry_after} seconds...")
            EventMachine::Timer.new(retry_after.to_i) do
              deliver(@notification)
            end
          end
        else
          message = "unexpected response: #{@http.response.inspect}"
          log_error(message)
          raise message
        end
      end

      def log_error(message)
        EM::C2DM.logger.error("#{@notification.uuid} failure (#{elapsed}ms): #{message}")
      end

      def elapsed
        ((Time.now.to_f - @start) * 1000.0).round # in milliseconds
      end

      def update_token
        new_token = @http.response_header["Update-Client-Auth"]
        return if new_token.nil? || new_token.empty?
        EM::C2DM.logger.info("received Update-Client-Auth. Setting new token.")
        EM::C2DM.token = new_token
      end
    end
  end
end
