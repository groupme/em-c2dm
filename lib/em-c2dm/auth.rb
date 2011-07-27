module EventMachine
  module C2DM
    class Auth
      CLIENT_LOGIN_URL = "https://www.google.com/accounts/ClientLogin"

      def self.authenticate(username, password)
        EM::C2DM.logger.info("authenticating as #{username}...")
        EM.run do
          http = EventMachine::HttpRequest.new(CLIENT_LOGIN_URL).post(
            :head   => { "Content-Length" => 0 },
            :query  => {
              "Email"       => username,
              "Passwd"      => password,
              "accountType" => "HOSTED_OR_GOOGLE",
              "service"     => "ac2dm"
            }
          )

          http.callback do
            http.response =~ /Auth=([a-z0-9\-_]+)$/i
            token = $1

            if token.nil? || token.empty?
              puts "error!"
              raise http.response.inspect
            else
              EM::C2DM.token = token
              EM::C2DM.logger.info("authentication success")
            end
            EM.stop
          end

          http.errback do |error|
            EM::C2DM.logger.error("authentication error: #{error.inspect}")
            EM.stop
          end
        end
      end
    end
  end
end
