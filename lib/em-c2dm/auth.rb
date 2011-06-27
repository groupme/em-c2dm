module EventMachine
  module C2DM
    class Auth
      CLIENT_LOGIN_URL = "https://www.google.com/accounts/ClientLogin"

      def self.authenticate(username, password)
        print "Authenticating with Google..."
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

            if token.nil? || token.emtpy?
              raise "error: blank token! #{http.response}"
            else
              puts "ok."
            end
            EM.stop
          end

          http.errback do |error|
            puts "Error! #{error.inspect}"
            EM.stop
          end
        end
      end
    end
  end
end
