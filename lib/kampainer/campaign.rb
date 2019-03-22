module Kampainer
  # See https://ws.campaigner.com/2013/01/campaignmanagement.asmx?WSDL

  # GetCampaignSummary
  class CampaignData < SchemaObject
    xml_name 'campaignData'
    xml_accessor :id, as: Integer
    xml_accessor :campaign_name
    xml_accessor :campaign_subject
    xml_accessor :campaign_format
    xml_accessor :campaign_status
    xml_accessor :campaign_type
    xml_accessor :html_content
    xml_accessor :txt_content
    xml_accessor :from_name
    xml_accessor :from_email_id, as: Integer
    xml_accessor :reply_email_id, as: Integer
    xml_accessor :track_replies?
    xml_accessor :auto_reply_message?
    xml_accessor :project_id, as: Integer
    xml_accessor :is_welcome_campaign?
    xml_accessor :date_modified
  end

  # GetCampaignSummary
  class CampaignRecipientsData < SchemaObject
    xml_reader :send_to_all_contacts?
    # TODO
  end

  class CampaignScheduleData < SchemaObject
    # TODO
  end

  class FromEmailDescription < SchemaObject
    xml_reader :id, as: Integer
    xml_reader :email_address
    xml_reader :from_email_status
  end
end
