module EventMachine
  module C2DM
    class Notification
      attr_reader :uuid, :options

      def initialize(registration_id, options = {})
        @registration_id, @options = registration_id, options
        raise ArgumentError.new("missing options") if options.nil? || options.empty?
        @uuid = $uuid.generate
      end

      def params
        @params ||= generate_params
      end

      private

      def generate_params
        params = { "registration_id" => @registration_id }
        params["collapse_key"] = @options.delete("collapse_key") if @options["collapse_key"]
        @options.each { |k,v| params["data.#{k}"] = v }
        puts params.inspect
        params
      end
    end
  end
end
