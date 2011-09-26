module EventMachine
  module C2DM
    class Notification
      attr_reader :uuid, :options, :registration_id

      def initialize(registration_id, options = {})
        @registration_id, @options = registration_id, options
        raise ArgumentError.new("missing options") if options.nil? || options.empty?
        @uuid = $uuid.generate
      end

      def params
        @params ||= generate_params
      end

      def headers
        {
          "Authorization"   => "GoogleLogin auth=#{EM::C2DM.token}",
          "Content-Length"  => 0,
          "User-Agent"      => "em-c2dm #{EM::C2DM::VERSION}"
        }
      end

      private

      def generate_params
        params = { "registration_id" => @registration_id }
        params["collapse_key"] = @options.delete(:collapse_key) || @options.delete("collapse_key")
        @options.each do |k,v|
          params["data.#{k}"] = v
        end
        params
      end
    end
  end
end
