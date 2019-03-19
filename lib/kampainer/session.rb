require 'logger'
require 'nokogiri'

module Kampainer
  class Session
    attr_reader :base_url
    attr_reader :username, :password
    attr_accessor :logger

    XMLNS = 'https://ws.campaigner.com/2013/01'.freeze

    def initialize(username:, password:, base_url: nil, logger: nil)
      @base_url = base_url || 'https://ws.campaigner.com/'
      @username = username
      @password = password
      @logger = logger || Logger.new('/dev/null')
    end

    # @option params [String] attribute_name
    # @option params [String] attribute_type
    # @option params [String|??] default_value
    # @return [Integer] attribute id
    def create_update_attribute(params)
      params.transform_keys! { |key| key.to_s.camelcase(:lower) }
      xml_request = build_xml_request('CreateUpdateAttribute', params)
      commit(contact_management_url, 'CreateUpdateAttribute', xml_request)[0].to_i
    end

    def delete_attribute(id)
      xml_request = build_xml_request('DeleteAttribute', id: id)
      commit(contact_management_url, 'DeleteAttribute', xml_request)
    end

    # @param *keys One or more keys of contacts to delete.
    def delete_contacts(*keys)
      contact_keys = ArrayOfContactKey[]
      keys.map { |key| contact_keys << Contact::Key.new(key) }
      xml_request = build_xml_request('DeleteContacts', contact_keys.to_xml)
      commit(contact_management_url, 'DeleteContacts', xml_request)[0].to_a
    end      

    # @param *keys One or more contact keys.
    def get_contacts(*keys)
      contact_keys = ContactKeys[]
      keys.map { |key| contact_keys << Contact::Key.new(key) }
      filter = ContactsDataFilter.new(keys: contact_keys)
      attribute_filter = ContactInformationFilter.new(include: 'static,custom,system')
      xml_request = build_xml_request('GetContacts', filter.to_xml, attribute_filter.to_xml)
      commit(contact_management_url, 'GetContacts', xml_request)[0].to_a
    end

    def immediate_upload(contact)
      contacts = Contacts.new(Array(contact))
      xml_request = build_xml_request('ImmediateUpload', contacts.to_xml)
      commit(contact_management_url, 'ImmediateUpload', xml_request)
    end

    # @option filters [Boolean] include_all_default_attributes
    # @option filters [Boolean] include_all_custom_attributes
    # @option filters [Boolean] include_all_system_attributes
    def list_attributes(filters)
      filter_xml = Attribute::Filter.new(filters).to_xml
      xml_request = build_xml_request('ListAttributes', filter_xml)
      commit(contact_management_url, 'ListAttributes', xml_request)
    end

    def list_test_contacts
      xml_request = build_xml_request('ListTestContacts')
      commit(contact_management_url, 'ListTestContacts', xml_request)
    end

    protected

    def build_xml_request(action_name, *nodes)
      RequestBody.new(action_name, username, password, nodes).to_xml
    end

    def contact_management_url
      "#{base_url}2013/01/contactmanagement.asmx"
    end

    def commit(url, action_name, xml_request)
      headers = {
        'SOAPAction' => "#{XMLNS}/#{action_name}",
        'Content-Type' => 'text/xml; charset=utf-8',
        'Content-Length' => xml_request.size.to_s
      }
      request = HttpRequest.new('POST', url, headers, logger)
      parse request.send("#{XMLNS}/#{action_name}", xml_request)
    end

    def parse(xml)
      xmldoc = Nokogiri::XML(xml)

      header = xmldoc.xpath('//soap:Header/*')
      response_header = Kampainer.const_get(header[0].name).from_xml(header[0].to_s)
      raise Error, response_header.message if response_header.error_flag?

      body = xmldoc.xpath('//soap:Body/*[1]')[0]

      response = []

      body.xpath('*')&.each do |node|
        node.elements.each do |childnode|
          response << Kampainer.const_get(childnode.name).from_xml(childnode.to_s)
        rescue
          response << childnode.inner_text
        end
      end

      response
    end
  end
end
