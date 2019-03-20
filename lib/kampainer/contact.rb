module Kampainer
  class Contact < SchemaObject

    class Key < SchemaObject
      xml_name 'ContactKey'
      xml_accessor :id, as: Integer, from: 'ContactId'
      xml_accessor :unique_identifier, from: 'ContactUniqueIdentifier'
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
  end

  class ContactKeys < SchemaCollection
    xml_reader :collection, as: [Contact::Key]
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

    def initialize(options)
      options.each do |k, v|
        @include_static_attributes = !!v if k.to_s =~ /static/ || v.to_s =~ /static/
        @include_custom_attributes = !!v if k.to_s =~ /custom/ || v.to_s =~ /custom/
        @include_system_attributes = !!v if k.to_s =~ /system/ || v.to_s =~ /system/
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

    xml_name 'ContactDetailData'
    xml_reader :key, as: Contact::Key, from: 'ContactKey'
    xml_reader :static_attributes, as: StaticAttributes
    xml_reader :custom_attributes, as: ArrayOfAttributeDetails, from: 'CustomAttributes'
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
    xml_accessor :key, as: Contact::Key, from: 'ContactKey'
    xml_accessor :result_description
  end

  # ListTestContacts
  class TestContact < Contact
    xml_accessor :email
  end

  # DeleteContacts
  class ArrayOfContactKey < SchemaCollection
    xml_name 'contactKeys'
    xml_reader :collection, as: [Contact::Key]
  end
end