RSpec.describe Kampainer do
  it "has a version number" do
    expect(Kampainer::VERSION).not_to be nil
  end

  let(:username) { ENV.fetch('CAMPAIGNER_USERNAME') }
  let(:password) { ENV.fetch('CAMPAIGNER_PASSWORD') }
  subject { Kampainer::Session.new(username: username, password: password) }

  before { subject.logger = Logger.new(STDOUT) if ENV['CAMPAIGNER_LOG'] }

  it "gets a list of attributes" do
    list = subject.list_attributes(
      include_all_default_attributes: true,
      include_all_custom_attributes: false,
      include_all_system_attributes: false)
    expect(list.length).to eq 6

    fname_attribute = list.find { |item| item.name == 'First Name' }
    expect(fname_attribute).to be_present
    expect(fname_attribute.static_attribute_id).to eq 1
    expect(fname_attribute.is_key?).to eq false
    expect(fname_attribute.attribute_type).to eq 'Default'
    expect(fname_attribute.data_type).to eq 'String'
  end

  describe "create attribute" do
    let(:custom_attribute_name) { "test-#{SecureRandom.hex}" }
    let(:custom_attribute) do
      {
        attribute_name: custom_attribute_name,
        attribute_type: 'String',
        default_value: 'test-default'
      }
    end

    it "creates a custom attribute" do
      attribute_id = subject.create_update_attribute(custom_attribute)
      expect(attribute_id).to be_a(Integer)

      custom_attributes = subject.list_attributes(include_all_custom_attributes: true)
      attribute = custom_attributes.find { |item| item.name == custom_attribute_name }
      expect(attribute).to be_present
      expect(attribute.id).to eq attribute_id

      subject.delete_attribute(attribute.id)
    end
  end

  it "gets a list of test contacts" do
    list = subject.list_test_contacts

    contact = list.first
    expect(contact.key.id).to be_present
    expect(contact.key.unique_identifier).to be_present
    expect(contact.first_name).to be_present
    expect(contact.last_name).to be_present
    expect(contact.email).to be_present
  end

  describe "gets contacts" do
    it "fails gracefully if invalid request" do
      expect do
        subject.get_contacts
      end.to raise_error Kampainer::Error, /INVALID_CONTACT_KEYS: Invalid ContactKeys. Cannot be null/
    end

    let(:test_contacts) { subject.list_test_contacts }
    let(:test_contact) { test_contacts.sample }

    it "gets a single contact by unique identifer" do
      contacts = subject.get_contacts(unique_identifier: test_contact.email)
      contact = contacts.first

      expect(contact.key.id).to eq test_contact.key.id
      # TODO: expect(contact.email).to eq test_contact.email
    end
  end
end
