require 'forwardable'
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

  # https://stackoverflow.com/questions/2844106/ruby-roxml-how-to-get-an-array-to-render-its-xml
  class SchemaCollection < SchemaObject
    extend Forwardable

    class << self
      alias_method :[], :new
    end
  end
end
