module Kampainer
  class AttributeDescription < SchemaObject
    # xml_accessor :id, from: 'Id' # account ID?
    xml_accessor :name
    xml_accessor :static_attribute_id, as: Integer
    xml_accessor :is_key?
    xml_accessor :attribute_type
    xml_accessor :data_type
    xml_accessor :last_modified_date # was LastUpdatedDate
  end
end
