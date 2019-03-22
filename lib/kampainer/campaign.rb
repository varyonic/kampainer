module Kampainer
  # See https://ws.campaigner.com/2013/01/campaignmanagement.asmx?WSDL

  class FromEmailDescription < SchemaObject
    xml_reader :id, as: Integer
    xml_reader :email_address
    xml_reader :from_email_status
  end
end
