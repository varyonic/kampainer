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

    # @param *keys One or more contact keys.
    def get_contacts(*keys)
      contact_keys = Contact::Keys[]
      keys.map { |key| contact_keys << Contact::Key.new(key) }
      filter = Contact::Filter.new(keys: contact_keys)
      xml_request = build_xml_request('GetContacts', filter.to_xml)
      commit(contact_management_url, 'GetContacts', xml_request)[0].to_a
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
        end
      end

      response
    end
  end
end
