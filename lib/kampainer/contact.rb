module Kampainer

  class ContactKey < SchemaObject
    xml_name 'ContactKey'
    xml_accessor :id, as: Integer, from: 'ContactId'
    xml_accessor :unique_identifier, from: 'ContactUniqueIdentifier'
  end

  class ArrayOfInt < SchemaCollection
    xml_accessor :collection, as: [Integer], from: 'int'
  end

  class Contact < SchemaObject
    class Key < ContactKey; end

    class CustomAttribute < SchemaObject
      xml_name 'CustomAttribute'
      xml_accessor :id, as: Integer, from: :attr
      xml_accessor :value, from: :content
    end

    class CustomAttributes < SchemaCollection
      xml_accessor :collection, as: [CustomAttribute]
    end

    xml_name 'ContactData'
    xml_accessor :key, as: Key, from: 'ContactKey'
    xml_accessor :first_name
    xml_accessor :last_name
    xml_accessor :email_address
    xml_accessor :phone
    xml_accessor :email_format
    xml_accessor :status
    xml_accessor :is_test_contact
    xml_accessor :custom_attributes, as: CustomAttributes
    xml_accessor :add_to_groups, as: ArrayOfInt

    def custom_attributes=(custom_attributes)
      custom_attributes = CustomAttributes.new(custom_attributes) if custom_attributes.is_a?(Array)
      @custom_attributes = custom_attributes
    end

    def add_to_groups=(group_ids)
      group_ids = ArrayOfInt.new(group_ids) unless group_ids.is_a?(SchemaObject)
      @add_to_groups = group_ids
    end
  end

  class ContactKeys < SchemaCollection
    xml_reader :collection, as: [Contact::Key]

    def initialize(keys = [])
      @collection = keys.map do |key|
        case key
        when Contact::Key then key
        when Integer then Contact::Key.new(id: key)
        when String then Contact::Key.new(unique_identifier: key)
        else Contact::Key.new(key)
        end
      end
    end
  end

  class ContactsDataFilter < SchemaObject
    xml_name 'contactFilter'
    xml_accessor :keys, as: ContactKeys, from: 'ContactKeys'
  end

  class ContactInformationFilter < SchemaObject
    xml_name 'contactInformationFilter' # GetContacts
    xml_accessor :include_static_attributes
    xml_accessor :include_custom_attributes
    xml_accessor :include_system_attributes
    xml_accessor :include_group_membership_data

    def initialize(options)
      options.each do |k, v|
        @include_static_attributes = !!v if k.to_s =~ /static/ || v.to_s =~ /static/
        @include_custom_attributes = !!v if k.to_s =~ /custom/ || v.to_s =~ /custom/
        @include_system_attributes = !!v if k.to_s =~ /system/ || v.to_s =~ /system/
        @include_group_membership_data = !!v if k.to_s =~ /group|member/ || v.to_s =~ /group|member/
      end
    end
  end

  # GetContacts
  class ContactDetailData < SchemaObject
    class StaticAttributes < SchemaObject
      xml_reader :first_name
      xml_reader :last_name
      xml_reader :email
      xml_reader :phone
      xml_reader :email_format
      xml_reader :status
      xml_reader :is_test_contact
    end

    class AttributeDetails < SchemaObject
      xml_name 'AttributeDetails'
      xml_reader :id, as: Integer
      xml_reader :name
      xml_reader :value
      xml_reader :default_value
    end

    class ArrayOfAttributeDetails < SchemaCollection
      xml_name 'CustomAttributes'
      xml_reader :collection, as: [AttributeDetails]
    end

    class ArrayOfContactGroupDescription < SchemaCollection
      xml_reader :collection, as: [ContactGroupDescription]
    end

    xml_name 'ContactDetailData'
    xml_reader :key, as: Contact::Key, from: 'ContactKey'
    xml_reader :static_attributes, as: StaticAttributes
    xml_reader :custom_attributes, as: ArrayOfAttributeDetails, from: 'CustomAttributes'
    xml_reader :contact_groups, as: ArrayOfContactGroupDescription, from: 'group_membership_data'
  end

  # GetContacts
  class ContactData < SchemaCollection
    xml_accessor :collection, as: [ContactDetailData]
  end

  # ImmediateUpload
  class Contacts < SchemaCollection
    xml_name 'contacts'
    xml_accessor :collection, as: [Contact]
  end

  # ImmediateUpload  
  class UploadResultData < SchemaObject
    xml_accessor :index, as: Integer
    xml_accessor :key, as: ContactKey, from: 'ContactKey'
    xml_accessor :result_description
  end

  # ListTestContacts
  class TestContact < Contact
    xml_accessor :email
  end

  # DeleteContacts
  class ArrayOfContactKey < ContactKeys
    xml_name 'contactKeys'
  end
end