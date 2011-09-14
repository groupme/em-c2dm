module EventMachine
  module C2DM
    # Header errors
    #   InvalidToken          - Authentication token is invalid. Reauthenticate.
    #   Retry_After           - Service is down for maintenance. Call retry_after for seconds to wait.
    #
    # Body errors
    #   Quota_Exceeded        - Too many messages sent by the sender. Retry after a while.
    #   Device_Quota_Exceeded - Too any messages sent by the sender to a specific device. Retry after a while.
    #   InvalidRegistration   - Missing or bad registration_id. Sender should stop sending messages to this device.
    #   NotRegistered         - The registration_id is no longer valid, for example user has uninstalled the application or turned off notifications. Sender should stop sending messages to this device.
    #   MessageTooBig         - The payload of the message is too big, see the limitations. Reduce the size of the message.
    #   MissingCollapseKey    - Collapse key is required. Include collapse key in the request.
    class Response
      attr_accessor :id, :status, :retry_after, :client_auth, :error

      def initialize(http = {})
        if http.kind_of?(Hash)
          @id           = http[:id]
          @status       = http[:status]
          @retry_after  = http[:retry_after]
          @client_auth  = http[:client_auth]
          @error        = http[:error]
        else
          parse_body(http.response)
          parse_headers(http.response_header)
        end
      end

      def success?
        @error.nil?
      end

      private

      def parse_body(body)
        body =~ (/^id=(.*)$/)
        @id = $1

        body =~ (/^Error=(.*)$/)
        @error = $1
      end

      # These are messed up because of EM::HttpRequest's messed up parsing
      def parse_headers(headers)
        @status = headers.status
        @retry_after = headers["RETRY_AFTER"].to_i
        @client_auth = headers["UPDATE_CLIENT_AUTH"]

        case @status
        when 401
          @error = "InvalidToken"
        when 502, 503
          @error = "RetryAfter"
        end
      end
    end
  end
end
