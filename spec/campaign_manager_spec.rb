RSpec.describe Kampainer do
  subject { Kampainer::CampaignManager.new(session) }

  before { subject.session.logger = Logger.new(STDOUT) if ENV['CAMPAIGNER_LOG'] }

  describe 'list from emails' do
    it 'fetches from emails' do
      emails = subject.list_from_emails
      expect(emails).to be_present
    end
  end
end
