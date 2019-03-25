module Kampainer
  # See https://ws.campaigner.com/2013/01/listmanagement.asmx?WSDL
  class ListManager
    attr_reader :session

    def initialize(session)
      @session = session
    end

    # @param [Hash] contact_group
    def create_update_contact_group(contact_group)
      params = [
        { contactGroupType: contact_group.type },
        { contactGroupId: contact_group.id || 0 },
        { name: contact_group.name },
        { description: contact_group.description },
        { isTempGroup: 'false' },
      ]
      call('CreateUpdateContactGroups', *params)[0].id
    end

    def delete_contact_groups(*ids)
      call('DeleteContactGroups', ContactGroupIds.new(ids).to_xml)
    end

    def list_contact_groups
      call('ListContactGroups')
    end

    protected

    def call(action_name, *params)
      session.call("#{session.base_url}2013/01/listmanagement.asmx", action_name, *params)
    end
  end
end
