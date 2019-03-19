module Kampainer
  class Attribute < SchemaObject
    class Filter < SchemaObject
      xml_name 'filter'
      xml_accessor :include_all_default_attributes?
      xml_accessor :include_all_custom_attributes?
      xml_accessor :include_all_system_attributes?
    end

    xml_accessor :id, as: Integer
    xml_accessor :name
    xml_accessor :static_attribute_id, as: Integer
    xml_accessor :is_key?
    xml_accessor :attribute_type
    xml_accessor :data_type
    xml_accessor :last_modified_date # was LastUpdatedDate
  end

  class AttributeDescription < Attribute; end
end
