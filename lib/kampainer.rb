require "kampainer/version"

require 'kampainer/schema_object'
require 'kampainer/contact_attribute'
require 'kampainer/contact.rb'

require 'kampainer/http_request'
require "kampainer/session"
require 'kampainer/request_body'
require 'kampainer/response'

module Kampainer
  class Error < StandardError; end
end
