class RequestBody < Nokogiri::XML::Builder
  def initialize(action_name, username, password, request)
    super()
    __send__('soap12:Envelope', {'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                                           'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                                           'xmlns:soap12' => 'http://www.w3.org/2003/05/soap-envelope'}) do |root|
      root.__send__('soap12:Body') do |body|
        body.__send__(action_name, xmlns: 'https://ws.campaigner.com/2013/01') do |doc|
          doc.authentication do
            doc.Username(username)
            doc.Password(password)
          end
          request.each { |node| body.parent << node }
        end
      end
    end
  end
end
