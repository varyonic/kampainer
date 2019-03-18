module Kampainer
  class Contact < SchemaObject

    class Key < SchemaObject
      xml_name 'ContactKey'
      xml_accessor :id, as: Integer, from: 'ContactId'
      xml_accessor :unique_identifier, from: 'ContactUniqueIdentifier'
    end

    class Keys < SchemaCollection
      xml_name 'ContactKeys'
      xml_reader :collection, as: [Key]
    end

    class Filter < SchemaObject
      xml_name 'contactFilter'
      xml_accessor :keys, as: Keys, from: 'ContactKeys'
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

  # GetContacts
  class ContactDetailData < Contact;
    xml_name 'ContactDetailData'
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