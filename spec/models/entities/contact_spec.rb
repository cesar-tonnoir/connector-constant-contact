require 'spec_helper'

describe Entities::Contact do
  describe 'class methods' do
    subject { Entities::Contact }

    it { expect(subject.connec_entity_name).to eql('Person') }
    it { expect(subject.external_entity_name).to eql('Contact') }
    it { expect(subject.mapper_class).to eql(ContactMapper) }
    it { expect(subject.object_name_from_connec_entity_hash({'first_name' => 'Jack', 'last_name' => 'The Ripper'})).to eql('Jack The Ripper') }
    it { expect(subject.object_name_from_external_entity_hash({'first_name' => 'Jack', 'last_name' => 'The Ripper'})).to eql('Jack The Ripper') }
  end

  describe 'instance methods' do

    subject { Entities::Contact.new }

    describe 'get_external_entities' do
      let!(:organization) { create(:organization, oauth_token: 'token') }
      let(:client) { Maestrano::Connector::Rails::External.get_client(organization) }
      let(:lists) {
        [
          {'id' => 'aaa', 'name' => 'Employee'},
          {'id' => 'bbb', 'name' => 'A random list'}
        ]
      }
      let(:contact1) { {'lists' => [{'id' => 'aaa', 'status' => 'ACTIVE'}]} }
      let(:contact2) { {'lists' => [{'id' => 'bbb', 'status' => 'ACTIVE'}, {'id' => 'aaa', 'status' => 'NOT ACTIVE'}]} }
      let(:contacts) { [contact1, contact2] }
      before {
        subject.send(:extract_specific_lists, lists)
        allow(client).to receive(:all).and_return(contacts)
      }

      it { expect(subject.get_external_entities(client, nil, organization)).to eql([contact2]) }
    end

    describe 'mappings' do
      describe 'map_to_external' do
        let(:connec_person) {
          {
            "id" => "3f58a011-5102-0132-65ff-600308937d74",
            "group_id" => "cld-f4g8r2g",
            "created_at" => "2014-11-18T03:38:13Z",
            "updated_at" => "2014-11-18T03:38:13Z",
            "title" => "Mr",
            "first_name" => "John",
            "last_name" => "Doe",
            "birth_date" => "1986-04-02T00:00:00Z",
            "organization_id" => "3f58c721-5102-0132-6600-600308937d74",
            "job_title" => "Sales Manager",
            "is_customer" => true,
            "is_supplier" => true,
            "is_lead" => true,
            "contact_channel" => {
              "skype" => "doecorp"
            },
            "address_work" => {
              "billing" => {
                "line1" => "86 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2086",
                "country" => "Australia"
              },
              "billing2" => {
                "line1" => "87 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2087",
                "country" => "AU"
              },
              "shipping" => {
                "line1" => "88 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2088",
                "country" => "AU"
              },
              "shipping2" => {
                "line1" => "89 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2089",
                "country" => "AU"
              }
            },
            "address_home" => {
              "billing" => {
                "line1" => "90 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2090",
                "country" => "AU"
              },
              "billing2" => {
                "line1" => "91 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2091",
                "country" => "AU"
              },
              "shipping" => {
                "line1" => "92 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2092",
                "country" => "AU"
              },
              "shipping2" => {
                "line1" => "93 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2093",
                "country" => "AU"
              }
            },
            "email" => {
              "address" => "john17@maestrano.com",
              "address2" => "jack17@example.com"
            },
            "website" => {
              "url" => "www.website17.com",
              "url2" => "www.mywebsite17.com"
            },
            "phone_work" => {
              "landline" => "+61 2 8574 1222",
              "landline2" => "+1 2 8574 1222",
              "mobile" => "+61 449 785 122",
              "mobile2" => "+1 449 785 122",
              "fax" => "+61 2 9974 1222",
              "fax2" => "+1 2 9974 1222",
              "pager" => "+61 440 785 122",
              "pager2" => "+1 440 785 122"
            },
            "phone_home" => {
              "landline" => "+61 2 8574 1223",
              "landline2" => "+1 2 8574 1223",
              "mobile" => "+61 449 785 123",
              "mobile2" => "+1 449 785 123",
              "fax" => "+61 2 9974 1223",
              "fax2" => "+1 2 9974 1223",
              "pager" => "+61 440 785 123",
              "pager2" => "+1 440 785 123"
            },
            "notes" => [
              {
                "id" => "546abf25ebe39067cb0000ce",
                "description" => "Something to be aware of!",
                "tag" => "123",
                "value" => "456"
              }
            ]
          }
        }

        let(:cc_contact) {
          {
            :first_name => "John",
            :last_name => "Doe",
            :prefix_name => "Mr",
            :job_title => "Sales Manager",
            :addresses => [
              {
                :line1 => "86 Elizabeth Street",
                :line2 => "",
                :city => "Sydney",
                :state => "NSW",
                :postal_code => "2086",
                :country_code => "AU",
                :address_type => "BUSINESS"
              }
            ],
            :email_addresses => [
              {
                :email_address => "john17@maestrano.com"
              }
            ],
            :work_phone => "+61 2 8574 1222",
            :home_phone => "+61 2 8574 1223",
            :cell_phone => "+61 449 785 123",
            :fax => "+61 2 9974 1223",
          }
        }

        before {
          subject.send(:extract_specific_lists, lists)
        }

        context 'when no specific list' do
          let(:lists) {[{'id' => 'id', 'name' => 'Main list'}]}
          it { expect(subject.map_to_external(connec_person, nil)).to eql(cc_contact.merge(lists: [{id: 'id'}])) }
        end

        context 'when customer and supplier lists' do
          before {
            connec_person.merge!('is_customer' => true, 'is_supplier' => true)
          }
          let(:customer_list) { {'id' => 'cust', 'name' => 'Customer'} }
          let(:supplier_list) { {'id' => 'supp', 'name' => 'Supplier'} }
          let(:lists) {[{'id' => 'id', 'name' => 'Main list'}, customer_list, supplier_list]}
          it { expect(subject.map_to_external(connec_person, nil)).to eql(cc_contact.merge(lists: [{id: customer_list['id']}, {id: supplier_list['id']}])) }
        end

        context 'when neither customer or supplier' do
          before {
            connec_person.merge!('is_customer' => false, 'is_supplier' => false)
          }
          let(:contact_list) { {'id' => 'cust', 'name' => 'Leads and other contacts'} }
          let(:lists) {[{'id' => 'id', 'name' => 'Main list'}, contact_list]}
          it { expect(subject.map_to_external(connec_person, nil)).to eql(cc_contact.merge(lists: [{id: contact_list['id']}])) }
        end
      end

      describe 'map_to_connec' do
        let(:cc_contact) {
          {
            "id" => "1992685500",
            "status" => "ACTIVE",
            "fax" => "",
            "addresses" => [
              {
                "id" => "1189c390-16bd-11e6-9c4f-d4ae52a45a09",
                "line1" => "23 some street",
                "line2" => "",
                "line3" => "",
                "city" => "Paris",
                "address_type" => "PERSONAL",
                "state_code" => "",
                "state" => "Idf",
                "country_code" => "fr",
                "postal_code" => "75010",
                "sub_postal_code" => ""
              }
            ],
            "notes" => notes,
            "confirmed" => false,
            "lists" => [
              {
                "id" => "1734115864",
                "status" => "ACTIVE"
              }
            ],
            "source" => "API",
            "email_addresses" => [
              {
                "id" => "5961cf20-16b6-11e6-89d7-d4ae52a45a09",
                "status" => "ACTIVE",
                "confirm_status" => "NO_CONFIRMATION_REQUIRED",
                "opt_in_source" => "ACTION_BY_OWNER",
                "opt_in_date" => "2016-05-10T13:51:52.000Z",
                "email_address" => "emp32@example.com"
              }
            ],
            "prefix_name" => "",
            "first_name" => "John",
            "middle_name" => "",
            "last_name" => "Doe",
            "job_title" => "Worker",
            "company_name" => company_name,
            "home_phone" => "0987654",
            "work_phone" => "567890",
            "cell_phone" => "",
            "custom_fields" => [],
            "created_date" => "2016-05-10T13:51:52.000Z",
            "modified_date" => "2016-05-10T14:40:43.000Z",
            "source_details" => "Maestrano - dev"
          }
        }

        let(:company_name) { nil }
        let(:notes) { nil }

        let(:connec_person) {
          {
            :first_name => "John",
            :last_name => "Doe",
            :title => "",
            :job_title => "Worker",
            :address_work => {
              :billing => {
                :line1 => "23 some street",
                :line2 => "",
                :city => "Paris",
                :region => "Idf",
                :postal_code => "75010",
                :country => "fr"
              }
            },
            :email => {
              :address => "emp32@example.com"
            },
            :phone_work => {
              :landline => "567890"
            },
            :phone_home => {
              :landline => "0987654",
              :mobile => "",
              :fax => ""
            },
          }
        }

        it { expect(subject.map_to_connec(cc_contact, nil)).to eql(connec_person) }

        describe 'company name' do
          context 'empty company_name' do
            let(:company_name) { '' }
            it { expect(subject.map_to_connec(cc_contact, nil)).to eql(connec_person) }
          end

          context 'non empty company name' do
            let(:company_name) { 'Some company' }
            it { expect(subject.map_to_connec(cc_contact, nil)).to eql(connec_person.merge(opts: {:attach_to_organization => "Some company"})) }
          end
        end

        describe 'notes' do
          let(:notes) {
            [
              {
                "id" => "33825bb0-16bd-11e6-9c4f-d4ae52a45a09",
                "note" => "a note",
                "created_date" => "2016-05-10T14:40:55.000Z",
                "modified_date" => "2016-05-10T14:40:55.000Z"
              }
            ]
          }
          it { expect(subject.map_to_connec(cc_contact, nil)).to eql(connec_person.merge(notes: [{:id=>"33825bb0-16bd-11e6-9c4f-d4ae52a45a09", :description=>"a note"}])) }
        end
      end
    end
  end
end
