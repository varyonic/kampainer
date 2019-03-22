RSpec.describe Kampainer::ListManager do
  subject { Kampainer::ListManager.new(session) }

  before { subject.session.logger = Logger.new(STDOUT) if ENV['CAMPAIGNER_LOG'] }

  let(:contact_group_name) { "test-#{SecureRandom.hex}" }
  let(:contact_group) do
    Kampainer::ContactGroup.new(type: 'MailingList', name: contact_group_name, description: "test")
  end

  it "creates/deletes contact group" do
    group_id = subject.create_update_contact_group(contact_group)
    download = subject.list_contact_groups.find { |group| group.id == group_id }

    expect(download.name).to eq contact_group_name
    # FIXME: expect(download.description).to eq contact_group.description # API has WSDL typo?

    subject.delete_contact_groups(group_id)
  end

  it "gets a list of contact groups" do
    groups = subject.list_contact_groups
    expect(groups).to be_present
  end
end
