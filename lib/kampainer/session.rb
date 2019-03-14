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

    def list_attributes
      xml_request = build_xml_request('ListAttributes')
      commit(contact_management_url, 'ListAttributes', xml_request)
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
