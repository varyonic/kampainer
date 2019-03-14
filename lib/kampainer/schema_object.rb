require 'roxml'

module Kampainer
  class SchemaObject
    include ROXML
    xml_convention :camelcase

    def initialize(options = {})
      options.each_pair { |k, v| send("#{k}=", v) }
    end

    def inspect
      variables = instance_variables - [:@roxml_references]
      s = variables.map { |iv| "#{iv}: #{instance_variable_get(iv).inspect}" }.join(', ')
      "<#{self.class.name}: #{s} >"
    end
  end
end
