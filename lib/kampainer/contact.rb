module Kampainer
  class Contact < SchemaObject

    class Key < SchemaObject
      xml_accessor :id, as: Integer, from: 'ContactId'
      xml_accessor :unique_identifier, from: 'ContactUniqueIdentifier'
    end

    xml_accessor :key, as: Key, from: 'ContactKey'
    xml_accessor :first_name
    xml_accessor :last_name
    xml_accessor :email
    xml_accessor :phone
    xml_accessor :email_format
    xml_accessor :status
  end

  class TestContact < Contact; end
end