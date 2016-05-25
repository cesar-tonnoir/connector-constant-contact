require 'spec_helper'

describe Entities::Account do
  describe 'class methods' do
    subject { Entities::Account }

    it { expect(subject.connec_entity_name).to eql('Company') }
    it { expect(subject.external_entity_name).to eql('Account') }
    it { expect(subject.mapper_class).to eql(AccountMapper) }
    it { expect(subject.object_name_from_connec_entity_hash({'name' => '123'})).to eql('123') }
    it { expect(subject.object_name_from_external_entity_hash({'organization_name' => '123'})).to eql('123') }
    it { expect(subject.singleton?).to be true }
    it { expect(subject.external_singleton?).to be true }
    it { expect(subject.no_date_filtering?).to be true }
    it { expect(subject.id_from_external_entity_hash({'email' => 'lala@mail.com'})).to eql('lala@mail.com') }
  end

  describe 'instance methods' do
    let!(:organization) { create(:organization, oauth_token: 'token') }
    let(:connec_client) { nil }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Entities::Account.new(organization, connec_client, external_client, opts) }

    describe 'mappings' do
      describe 'map_to_external' do
        let(:connec_company) {
          {
            "id" => "5724bcf1-5103-0132-6651-600308937d74",
            "group_id" => "cld-7gr8e5",
            "created_at" => "2014-11-18T03:45:59Z",
            "updated_at" => "2014-11-18T03:45:59Z",
            "name" => "My Company",
            "currency" => "USD",
            "note" => "This is my own company profile",
            "timezone" => "+10:00",
            "industry" => "IT",
            "managers" => "John Doe (CTO)",
            "capital" => 42000,
            "juridical_status" => "Pty",
            "tax_number" => "01234567891",
            "business_number" => "01234567891",
            "employer_id" => "01234567891",
            "fiscal_year_first_month" => "January",
            "email" => {
              "address" => "john27@maestrano.com",
              "address2" => "jack27@example.com"
            },
            "address" => {
              "billing" => {
                "line1" => "118 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2118",
                "country" => "AU"
              },
              "billing2" => {
                "line1" => "119 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2119",
                "country" => "AU"
              },
              "shipping" => {
                "line1" => "120 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2120",
                "country" => "AU"
              },
              "shipping2" => {
                "line1" => "121 Elizabeth Street",
                "line2" => "",
                "city" => "Sydney",
                "region" => "NSW",
                "postal_code" => "2121",
                "country" => "AU"
              }
            },
            "website" => {
              "url" => "www.website27.com",
              "url2" => "www.mywebsite27.com"
            },
            "phone" => {
              "landline" => "+61 2 8574 1230",
              "landline2" => "+1 2 8574 1230",
              "mobile" => "+61 449 785 130",
              "mobile2" => "+1 449 785 130",
              "fax" => "+61 2 9974 1230",
              "fax2" => "+1 2 9974 1230",
              "pager" => "+61 440 785 130",
              "pager2" => "+1 440 785 130"
            },
            "logo" => {
              "logo" => "http://s3.images/logo.png",
              "thumb" => "http://s3.images/thumb.png",
              "mini_thumb" => "http://s3.images/mini_thumb.png"
            }
          }
        }

        let(:cc_account) {
          {
            :organization_name => "My Company",
            :email => "john27@maestrano.com",
            :website => "www.website27.com",
            :phone => "+61 2 8574 1230",
            :organization_addresses => [
              {
                :line1 => "118 Elizabeth Street",
                :line2 => "",
                :city => "Sydney",
                :postal_code => "2118",
                :country_code => "AU"
              }
            ]
          }.with_indifferent_access
        }

        it { expect(subject.map_to_external(connec_company)).to eql(cc_account) }
      end

      describe 'map_to_connec' do
        let(:cc_account) {
          {
            "website" => "http://none",
            "organization_name" => "pp",
            "time_zone" => "US/Eastern",
            "first_name" => "pp",
            "last_name" => "pp",
            "email" => "ccsb1@yopmail.com",
            "phone" => "440876543212",
            "company_logo" => "",
            "country_code" => "GB",
            "state_code" => "",
            "organization_addresses" => []
          }
        }

        let(:connec_company) {
          {
            :name => "pp",
            :id => [{"id"=>"ccsb1@yopmail.com", "provider"=>"this-app", "realm"=>"this-realm"}],
            :email => {
              :address => "ccsb1@yopmail.com"
            },
            :website => {
              :url => "http://none"
            },
            :phone => {
              :landline => "440876543212"
            }
          }.with_indifferent_access
        }

        it { expect(subject.map_to_connec(cc_account)).to eql(connec_company) }
      end
    end
  end
end
