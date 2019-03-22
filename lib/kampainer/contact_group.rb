module Kampainer

  # ListContactGroups
  class ContactGroupDescription < SchemaObject
    xml_reader :type
    xml_reader :id
    xml_reader :name
    xml_reader :description
    xml_reader :status
    xml_reader :last_modified_date
    xml_reader :project_id
  end
end
