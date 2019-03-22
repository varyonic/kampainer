module Kampainer
  # See https://ws.campaigner.com/2013/01/campaignmanagement.asmx?WSDL
  class CampaignManager
    attr_reader :session

    def initialize(session)
      @session = session
    end

    def list_from_emails
      call('ListFromEmails')
    end

    protected

    def call(action_name, *params)
      session.call("#{session.base_url}2013/01/campaignmanagement.asmx", action_name, *params)
    end
  end
end
