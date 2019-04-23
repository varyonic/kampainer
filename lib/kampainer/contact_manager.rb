module Kampainer
  # See https://ws.campaigner.com/2013/01/contactmanagement.asmx?WSDL
  class ContactManager
    attr_reader :session

    def initialize(session)
      @session = session
    end

    # @option params [String] attribute_name
    # @option params [String] attribute_type
    # @option params [String|??] default_value
    # @return [Integer] attribute id
    def create_update_attribute(params)
      params.transform_keys! { |key| key.to_s.camelcase(:lower) }
      call('CreateUpdateAttribute', params)[0].to_i
    end

    def delete_attribute(id)
      call('DeleteAttribute', id: id)
    end

    # @param *keys One or more keys of contacts to delete.
    def delete_contacts(*keys)
      contact_keys = ArrayOfContactKey[keys]
      call('DeleteContacts', contact_keys.to_xml)[0].to_a
    end

    # @param *keys One or more contact keys.
    def get_contacts(*keys)
      filter = ContactsDataFilter.new(keys: ContactKeys[keys])
      attribute_filter = ContactInformationFilter.new(include: 'static,custom,groups')
      call('GetContacts', filter.to_xml, attribute_filter.to_xml)[0].to_a
    end

    # @return [ContactKey]
    def immediate_upload(contact)
      contact.key ||= ContactKey.new(unique_identifier: contact.email_address, id: 0)
      contacts = Contacts.new(Array(contact))
      call('ImmediateUpload', contacts.to_xml)[0].key
    end

    # @option filters [Boolean] include_all_default_attributes
    # @option filters [Boolean] include_all_custom_attributes
    # @option filters [Boolean] include_all_system_attributes
    def list_attributes(filters)
      filter_xml = Attribute::Filter.new(filters).to_xml
      call('ListAttributes', filter_xml)
    end

    def list_test_contacts
      call('ListTestContacts')
    end

    protected

    def call(action_name, *params)
      session.call("#{session.base_url}2013/01/contactmanagement.asmx", action_name, *params)
    end
  end
end
