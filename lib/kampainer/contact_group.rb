module Kampainer

  # ListContactGroups
  class ContactGroupDescription < SchemaObject
    xml_name 'ContactGroupDescription'
    xml_reader :type
    xml_reader :id
    xml_reader :name
    xml_reader :description
    xml_reader :status
    xml_reader :last_modified_date
    xml_reader :project_id
  end

  # CreateContactGroups
  class ContactGroup < ContactGroupDescription
    attr_accessor :type, :id, :name, :description
  end

  class ContactGroupId < SchemaObject
    xml_reader :id, from: :content
  end

  class ContactGroupIds < SchemaCollection
    xml_accessor :collection, as: [Integer], from: 'int'
  end
end
