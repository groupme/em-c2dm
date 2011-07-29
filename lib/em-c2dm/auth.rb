require "net/https"
require "uri"

module EventMachine
  module C2DM
    class Auth
      CLIENT_LOGIN_URL = "https://www.google.com/accounts/ClientLogin"

      # This call blocks the reactor intentionally. All work must cease
      # until we've obtained a valid token.
      def self.authenticate(username, password)
        EM::C2DM.logger.info("authenticating as #{username}...")

        uri = URI.parse(CLIENT_LOGIN_URL)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file = '/usr/lib/ssl/certs/ca-certificates.crt' # for heroku, may differ on your platform

        request = Net::HTTP::Post.new(uri.path)
        request["Content-Length"] = 0
        request.set_form_data({
          "Email"       => username,
          "Passwd"      => password,
          "accountType" => "HOSTED_OR_GOOGLE",
          "service"     => "ac2dm"
        })

        response = http.request(request)

        case response
        when Net::HTTPSuccess
          response.body =~ /Auth=([a-z0-9\-_]+)$/i
          token = $1

          if token.nil? || token.empty?
            puts "error!"
            raise response.body.inspect
          end

          EM::C2DM.token = token
          EM::C2DM.logger.info("authentication success")
          true
        else
          EM::C2DM.logger.error("authentication error: #{response.inspect}")
          false
        end
      end
    end
  end
end
