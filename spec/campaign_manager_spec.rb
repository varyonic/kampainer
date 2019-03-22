RSpec.describe Kampainer do
  let(:from_email) { subject.list_from_emails.first }
  subject { Kampainer::CampaignManager.new(session) }

  before { subject.session.logger = Logger.new(STDOUT) if ENV['CAMPAIGNER_LOG'] }

  describe "create update campaign" do
    let(:campaign) do
      Kampainer::CampaignData.new(
        campaign_name: "test-#{SecureRandom.hex}",
        campaign_subject: "test",
        campaign_format: 'Text',
        campaign_status: 'Incomplete',
        campaign_type: 'None',
        txt_content: 'Howdy',
        from_name: 'Ben',
        from_email_id: from_email.id,
        reply_email_id: from_email.id
      )
    end

    it "creates/gets/delete a campaign" do
      campaign_id = subject.create_update_campaign(campaign)
      download = subject.get_campaign_summary(campaign_id)[0]

      expect(download.campaign_name).to eq campaign.campaign_name
      expect(download.campaign_subject).to eq campaign.campaign_subject
      expect(download.campaign_format).to eq campaign.campaign_format
      expect(download.campaign_status).to eq campaign.campaign_status
      expect(download.campaign_type).to eq campaign.campaign_type
      expect(download.txt_content).to eq campaign.txt_content
      expect(download.from_name).to eq campaign.from_name
      expect(download.from_email_id).to eq campaign.from_email_id
      expect(download.reply_email_id).to eq campaign.reply_email_id

      subject.delete_campaign(campaign_id)
    end
  end

  describe 'list from emails' do
    it 'fetches from emails' do
      emails = subject.list_from_emails
      expect(emails).to be_present
    end
  end
end
