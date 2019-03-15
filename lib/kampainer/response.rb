module Kampainer
  class ResponseHeader < SchemaObject
    xml_accessor :error_flag?
    xml_accessor :return_code
    xml_accessor :return_message

    def message
      "#{return_code}: #{return_message}"
    end
  end
end
