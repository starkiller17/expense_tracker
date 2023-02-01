module Helpers
  module Utils
    def json_response
      @json_response ||= JSON.parse(last_response.body)
    end
  end
end