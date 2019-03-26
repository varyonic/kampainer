module Kampainer
  class Attribute < SchemaObject
    class Filter < SchemaObject
      xml_name 'filter'
      xml_accessor :include_all_default_attributes?
      xml_accessor :include_all_custom_attributes?
      xml_accessor :include_all_system_attributes?

      def initialize(options)
        @include_all_default_attributes = false
        @include_all_custom_attributes = false
        @include_all_system_attributes = false
        options.each do |k, v|
          @include_all_default_attributes = !!v if k.to_s =~ /default/ || v.to_s =~ /default/
          @include_all_custom_attributes = !!v if k.to_s =~ /custom/ || v.to_s =~ /custom/
          @include_all_system_attributes = !!v if k.to_s =~ /system/ || v.to_s =~ /system/
        end
      end
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
