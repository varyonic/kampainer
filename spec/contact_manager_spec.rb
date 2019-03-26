RSpec.describe Kampainer do
  def contact_manager
    username = ENV.fetch('CAMPAIGNER_USERNAME')
    password = ENV.fetch('CAMPAIGNER_PASSWORD')
    session = Kampainer::Session.new(username: username, password: password)
    Kampainer::ContactManager.new(session)
  end

  def setup_test_attribute
    @test_attribute_name = "test-#{SecureRandom.hex}"
    @test_attribute_id = contact_manager.create_update_attribute(
      attribute_name: @test_attribute_name,
      attribute_type: 'String',
      default_value: 'test-default')
  end

  def cleanup_test_attribute
    contact_manager.delete_attribute(@test_attribute_id)
  end

  def cleanup_all_test_attributes
    attrs = session.list_attributes(include_all_custom_attributes: true)
    ids = attrs.select { |attr| attr.name =~ /^test/ }.map(&:id)
    ids.each { |id| contact_manager.delete_attribute(id) }
  end

  def cleanup_all_test_contacts
    test_contacts = session.list_test_contacts
    smiths = test_contacts.select { |c| c.last_name == 'Smith' }
    smiths.pop
    contact_manager.delete_contacts *smiths.map { |c| Hash[id: c.key.id] }
  end

  it "has a version number" do
    expect(Kampainer::VERSION).not_to be nil
  end

  let(:username) { ENV.fetch('CAMPAIGNER_USERNAME') }
  let(:password) { ENV.fetch('CAMPAIGNER_PASSWORD') }
  let(:session) { Kampainer::Session.new(username: username, password: password) }
  subject { Kampainer::ContactManager.new(session) }

  before { subject.session.logger = Logger.new(STDOUT) if ENV['CAMPAIGNER_LOG'] }

  it "gets a list of attributes" do
    list = subject.list_attributes(only: :default)
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
      contacts = subject.get_contacts(test_contact.key.id) # get_contacts(Integer)
      contact = contacts.first

      expect(contact.key.id).to eq test_contact.key.id
      expect(contact.static_attributes.email).to eq test_contact.email
    end
  end

  describe "immediate upload" do
    let(:contact) do
      email = "#{SecureRandom.hex}@example.com"
      Kampainer::Contact.new(
        first_name: 'John',
        last_name: 'Smith',
        email_address: email,
        phone: '555-555-5555',
        email_format: 'HTML',
        is_test_contact: true,
        key: Kampainer::ContactKey.new(unique_identifier: email, id: 0)
      )
    end

    it "posts a contact" do
      subject.immediate_upload(contact)
      download = subject.get_contacts(contact.email_address).first # get_contacts(String)
      expect(download.key.unique_identifier).to eq contact.key.unique_identifier

      subject.delete_contacts(id: download.key.id)
    end
  end

  context "custom attribute defined" do
    let(:custom_attribute_name) { @test_attribute_name }
    let(:custom_attribute_id) { @test_attribute_id }

    before(:all) do
      setup_test_attribute
    end
    after(:all) do
      cleanup_test_attribute
    end

    describe "gets contacts" do
      let(:test_contacts) { subject.list_test_contacts }
      let(:test_contact) { test_contacts.sample }

      it "gets a single contact by unique identifer" do
        contact = subject.get_contacts(unique_identifier: test_contact.email).first # get_contacts(Hash)
        custom_value = contact.custom_attributes.to_a.find { |ca| ca.id == custom_attribute_id }
        expect(custom_value.default_value).to eq 'test-default'
      end
    end

    describe "immediate upload" do
      let(:custom_attribute_value) do
        Kampainer::Contact::CustomAttribute.new(id: custom_attribute_id, value: 'xxzzy')
      end
      let(:contact) do
        email = "#{SecureRandom.hex}@example.com"
        Kampainer::Contact.new(
          first_name: 'John',
          last_name: 'Smith',
          email_address: email,
          phone: '555-555-5555',
          email_format: 'HTML',
          is_test_contact: true,
          custom_attributes: Kampainer::Contact::CustomAttributes.new([custom_attribute_value]),
          key: Kampainer::ContactKey.new(unique_identifier: email, id: 0)
        )
      end

      it "posts a contact" do
        subject.immediate_upload(contact)
        download = subject.get_contacts(unique_identifier: contact.email_address).first
        expect(download.key.unique_identifier).to eq contact.key.unique_identifier
        custom_value = download.custom_attributes.to_a.find { |ca| ca.id == custom_attribute_id }
        expect(custom_value.value).to eq 'xxzzy'

        subject.delete_contacts(download.key.id) # delete_contacts(Integer)
      end
    end
  end
end
