module EventMachine
  module C2DM
    class Client
      class InvalidToken < StandardError;end
      class RetryAfter < StandardError;end

      URL = "https://android.apis.google.com/c2dm/send"

      def deliver(notification)
        @start = Time.now.to_f
        @notification = notification
        raise "token not set!" unless EM::C2DM.token
        log("send start")
        @http = EventMachine::HttpRequest.new(URL).post(
          :query  => @notification.params,
          :head   => {
            "Authorization"   => "GoogleLogin auth=#{EM::C2DM.token}",
            "Content-Length"  => 0,
            "User-Agent"      => "em-c2dm #{EM::C2DM::VERSION}"
          }
        )
        @http.callback  { on_complete }
        @http.errback   { |e| error(e.inspect) }
      end

      private


      # TODO Implement error codes for 200 OK responses
      # id=[ID of sent message]
      # Error=[error code]
      #   QuotaExceeded — Too many messages sent by the sender. Retry after a while.
      #   DeviceQuotaExceeded — Too many messages sent by the sender to a specific device. Retry after a while.
      #   InvalidRegistration — Missing or bad registration_id. Sender should stop sending messages to this device.
      #   NotRegistered — The registration_id is no longer valid, for example user has uninstalled the application or turned off notifications. Sender should stop sending messages to this device.
      #   MessageTooBig — The payload of the message is too big, see the limitations. Reduce the size of the message.
      #   MissingCollapseKey — Collapse key is required. Include collapse key in the request.
      def on_complete
        update_token

        code = @http.response_header.status.to_i
        if code == 200
          log("ok: #{@http.response.strip}")
        else
          on_failure(code)
        end
      end

      def on_failure(code)
        case code
        when 401
          error("invalid auth token")
          raise InvalidToken.new
        when 502, 503
          error("service unavilable")
          if retry_after = @http.response_header["Retry-After"]
            error("retry after #{retry_after} seconds")
            raise RetryAfter.new(retry_after.to_i)
          end
        else
          error("unexpected response code #{code} - #{@http.inspect}")
        end
      end

      def update_token
        new_token = @http.response_header["Update-Client-Auth"]
        return if new_token.nil? || new_token.empty?
        EM::C2DM.token = new_token
        log("received update-client-auth, new token set")
      end

      def elapsed
        ((Time.now.to_f - @start) * 1000.0).round # in milliseconds
      end

      def log(message)
        EM::C2DM.logger.info("#{message} uuid=#{@notification.uuid} time=#{elapsed}ms")
      end

      def error(message)
        EM::C2DM.logger.error("error: #{message} uuid=#{@notification.uuid} time=#{elapsed}ms")
      end
    end
  end
end
