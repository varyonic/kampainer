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

    xml_accessor :key, as: Key, from: 'ContactKey'
    xml_accessor :first_name
    xml_accessor :last_name
    xml_accessor :email_address
    xml_accessor :phone
    xml_accessor :email_format
    xml_accessor :status
  end

  # GetContacts
  class ContactDetailData < Contact;
    xml_name 'ContactDetailData'
  end

  # GetContacts
  class ContactData < SchemaCollection
    xml_accessor :collection, as: [ContactDetailData]
  end


  # ListTestContacts
  class TestContact < Contact
    xml_accessor :email
  end
end