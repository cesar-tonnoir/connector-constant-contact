class Entities::Person < Maestrano::Connector::Rails::Entity

  COUNTRY_CODES = {:AD=>"Andorra", :AE=>"United Arab Emirates", :AF=>"Afghanistan", :AG=>"Antigua and Barbuda", :AI=>"Anguilla", :AL=>"Albania", :AM=>"Armenia", :AO=>"Angola", :AQ=>"Antarctica", :AR=>"Argentina", :AS=>"American Samoa", :AT=>"Austria", :AU=>"Australia", :AW=>"Aruba", :AX=>"Åland", :AZ=>"Azerbaijan", :BA=>"Bosnia and Herzegovina", :BB=>"Barbados", :BD=>"Bangladesh", :BE=>"Belgium", :BF=>"Burkina Faso", :BG=>"Bulgaria", :BH=>"Bahrain", :BI=>"Burundi", :BJ=>"Benin", :BL=>"Saint-Barthélemy", :BM=>"Bermuda", :BN=>"Brunei", :BO=>"Bolivia", :BQ=>"Bonaire", :BR=>"Brazil", :BS=>"Bahamas", :BT=>"Bhutan", :BW=>"Botswana", :BY=>"Belarus", :BZ=>"Belize", :CA=>"Canada", :CC=>"Cocos [Keeling] Islands", :CD=>"Congo", :CF=>"Central African Republic", :CG=>"Republic of the Congo", :CH=>"Switzerland", :CI=>"Ivory Coast", :CK=>"Cook Islands", :CL=>"Chile", :CM=>"Cameroon", :CN=>"China", :CO=>"Colombia", :COUNTRY_ISO_CODE=>"country_name", :CR=>"Costa Rica", :CU=>"Cuba", :CV=>"Cape Verde", :CW=>"Curaçao", :CX=>"Christmas Island", :CY=>"Cyprus", :CZ=>"Czech Republic", :DE=>"Germany", :DJ=>"Djibouti", :DK=>"Denmark", :DM=>"Dominica", :DO=>"Dominican Republic", :DZ=>"Algeria", :EC=>"Ecuador", :EE=>"Estonia", :EG=>"Egypt", :ER=>"Eritrea", :ES=>"Spain", :ET=>"Ethiopia", :FI=>"Finland", :FJ=>"Fiji", :FK=>"Falkland Islands", :FM=>"Federated States of Micronesia", :FO=>"Faroe Islands", :FR=>"France", :GA=>"Gabon", :GB=>"United Kingdom", :GD=>"Grenada", :GE=>"Georgia", :GF=>"French Guiana", :GG=>"Guernsey", :GH=>"Ghana", :GI=>"Gibraltar", :GL=>"Greenland", :GM=>"Gambia", :GN=>"Guinea", :GP=>"Guadeloupe", :GQ=>"Equatorial Guinea", :GR=>"Greece", :GS=>"South Georgia and the South Sandwich Islands", :GT=>"Guatemala", :GU=>"Guam", :GW=>"Guinea-Bissau", :GY=>"Guyana", :HK=>"Hong Kong", :HN=>"Honduras", :HR=>"Croatia", :HT=>"Haiti", :HU=>"Hungary", :ID=>"Indonesia", :IE=>"Ireland", :IL=>"Israel", :IM=>"Isle of Man", :IN=>"India", :IO=>"British Indian Ocean Territory", :IQ=>"Iraq", :IR=>"Iran", :IS=>"Iceland", :IT=>"Italy", :JE=>"Jersey", :JM=>"Jamaica", :JO=>"Hashemite Kingdom of Jordan", :JP=>"Japan", :KE=>"Kenya", :KG=>"Kyrgyzstan", :KH=>"Cambodia", :KI=>"Kiribati", :KM=>"Comoros", :KN=>"Saint Kitts and Nevis", :KP=>"North Korea", :KR=>"Republic of Korea", :KW=>"Kuwait", :KY=>"Cayman Islands", :KZ=>"Kazakhstan", :LA=>"Laos", :LB=>"Lebanon", :LC=>"Saint Lucia", :LI=>"Liechtenstein", :LK=>"Sri Lanka", :LR=>"Liberia", :LS=>"Lesotho", :LT=>"Republic of Lithuania", :LU=>"Luxembourg", :LV=>"Latvia", :LY=>"Libya", :MA=>"Morocco", :MC=>"Monaco", :MD=>"Republic of Moldova", :ME=>"Montenegro", :MF=>"Saint Martin", :MG=>"Madagascar", :MH=>"Marshall Islands", :MK=>"Macedonia", :ML=>"Mali", :MM=>"Myanmar [Burma]", :MN=>"Mongolia", :MO=>"Macao", :MP=>"Northern Mariana Islands", :MQ=>"Martinique", :MR=>"Mauritania", :MS=>"Montserrat", :MT=>"Malta", :MU=>"Mauritius", :MV=>"Maldives", :MW=>"Malawi", :MX=>"Mexico", :MY=>"Malaysia", :MZ=>"Mozambique", :NA=>"Namibia", :NC=>"New Caledonia", :NE=>"Niger", :NF=>"Norfolk Island", :NG=>"Nigeria", :NI=>"Nicaragua", :NL=>"Netherlands", :NO=>"Norway", :NP=>"Nepal", :NR=>"Nauru", :NU=>"Niue", :NZ=>"New Zealand", :OM=>"Oman", :PA=>"Panama", :PE=>"Peru", :PF=>"French Polynesia", :PG=>"Papua New Guinea", :PH=>"Philippines", :PK=>"Pakistan", :PL=>"Poland", :PM=>"Saint Pierre and Miquelon", :PN=>"Pitcairn Islands", :PR=>"Puerto Rico", :PS=>"Palestine", :PT=>"Portugal", :PW=>"Palau", :PY=>"Paraguay", :QA=>"Qatar", :RE=>"Réunion", :RO=>"Romania", :RS=>"Serbia", :RU=>"Russia", :RW=>"Rwanda", :SA=>"Saudi Arabia", :SB=>"Solomon Islands", :SC=>"Seychelles", :SD=>"Sudan", :SE=>"Sweden", :SG=>"Singapore", :SH=>"Saint Helena", :SI=>"Slovenia", :SJ=>"Svalbard and Jan Mayen", :SK=>"Slovakia", :SL=>"Sierra Leone", :SM=>"San Marino", :SN=>"Senegal", :SO=>"Somalia", :SR=>"Suriname", :SS=>"South Sudan", :ST=>"São Tomé and Príncipe", :SV=>"El Salvador", :SX=>"Sint Maarten", :SY=>"Syria", :SZ=>"Swaziland", :TC=>"Turks and Caicos Islands", :TD=>"Chad", :TF=>"French Southern Territories", :TG=>"Togo", :TH=>"Thailand", :TJ=>"Tajikistan", :TK=>"Tokelau", :TL=>"East Timor", :TM=>"Turkmenistan", :TN=>"Tunisia", :TO=>"Tonga", :TR=>"Turkey", :TT=>"Trinidad and Tobago", :TV=>"Tuvalu", :TW=>"Taiwan", :TZ=>"Tanzania", :UA=>"Ukraine", :UG=>"Uganda", :UM=>"U.S. Minor Outlying Islands", :US=>"United States", :UY=>"Uruguay", :UZ=>"Uzbekistan", :VA=>"Vatican City", :VC=>"Saint Vincent and the Grenadines", :VE=>"Venezuela", :VG=>"British Virgin Islands", :VI=>"U.S. Virgin Islands", :VN=>"Vietnam", :VU=>"Vanuatu", :WF=>"Wallis and Futuna", :WS=>"Samoa", :XK=>"Kosovo", :YE=>"Yemen", :YT=>"Mayotte", :ZA=>"South Africa", :ZM=>"Zambia", :ZW=>"Zimbabwe"}
  def self.connec_entity_name
    'Person'
  end

  def self.external_entity_name
    'Contact'
  end

  def self.mapper_class
    PersonMapper
  end

  def get_external_entities(client, last_synchronization, organization, opts={})
    @lists = client.class.get("/lists?api_key=#{client.instance_variable_get(:@api_key)}", :headers => client.instance_variable_get(:@headers))
    super
  end

  def map_to_external(entity, organization)
    mapped_entity = super
    mapped_entity.merge(lists: [id: @lists.first["id"]])
  end

  def get_connec_entities(client, last_synchronization, organization, opts={})
    super(client, last_synchronization, organization, opts.merge(:$filter => "type eq 'MANUAL'")) #change the filter
  end

  def self.object_name_from_connec_entity_hash(entity)
    "#{entity['first_name']} #{entity['last_name']}"
  end

  def self.object_name_from_external_entity_hash(entity)
    "#{entity['FirstName']} #{entity['LastName']}"
  end

end

class PersonMapper
  extend HashMapper

  map from('first_name'), to('first_name')
  map from('last_name'), to('last_name'), default: 'Undefined'
  map from('address_work/billing/line1'), to('addresses[0]/address1')
  map from('address_work/billing/line2'), to('addresses[0]/address2')
  map from('address_work/billing/city'), to('addresses[0]/city')
  map from('address_work/billing/region'), to('addresses[0]/state')
  map from('address_work/billing/postal_code'), to('addresses[0]/postal_code')
  map from('address_work/billing/country'), to('addresses[0]/country_code')
  map from('email/address'), to('email_addresses[0]/email_address'), default: 'default@yopmail.com'
  map from('status'), to('lists[0]/status')



    after_normalize do |input, output|

      if output[:addresses].blank?
        output[:addresses] = []
        output[:addresses][0] = {}
      else
        output[:addresses][0][:country_code] = Entities::Person::COUNTRY_CODES.key(output[:addresses][0][:country_code])
      end
      output[:addresses][0][:address_type] = input["address_work"]["billing"].present? ? "BUSINESS" : "PERSONAL"
      output
    end

end
