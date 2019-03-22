module Kampainer
  # See https://ws.campaigner.com/2013/01/listmanagement.asmx?WSDL
  class ListManager
    attr_reader :session

    def initialize(session)
      @session = session
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
