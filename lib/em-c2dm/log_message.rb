module EventMachine
  module C2DM
    class LogMessage
      def initialize(notification, response)
        @notification, @response = notification, response
      end

      def log
        if @response.success?
          EM::C2DM.logger.info(message)
        else
          EM::C2DM.logger.error(message)
        end
      end

      private

      def message
        parts = [
          "CODE=#{@response.status}",
          "GUID=#{@notification.uuid}",
          "TOKEN=#{@notification.registration_id}",
          "TIME=#{@response.duration}"
        ]
        parts << "ERROR=#{@response.error}" unless @response.success?
        parts.join(" ")
      end
    end
  end
end
