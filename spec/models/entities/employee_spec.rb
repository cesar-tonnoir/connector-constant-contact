require 'spec_helper'

describe Entities::Employee do
  describe 'class methods' do
    subject { Entities::Employee }

    it { expect(subject.connec_entity_name).to eql('Employee') }
    it { expect(subject.external_entity_name).to eql('Contact') }
    it { expect(subject.mapper_class).to eql(EmployeeMapper) }
    it { expect(subject.object_name_from_connec_entity_hash({'first_name' => 'Jack', 'last_name' => 'The Ripper'})).to eql('Jack The Ripper') }
    it { expect(subject.can_read_external?).to be false }
  end

  describe 'instance methods' do

    subject { Entities::Employee.new }

    describe 'map_to_external' do
      let(:connec_employee) {
        {
          "id" => "68d63921-bee9-0132-2fbd-56847afe9799",
          "code" => "EM9110",
          "first_name" => "Benjamin",
          "last_name" => "Wilson",
          "employee_id" => "001450",
          "mno_user_id" => "usr-afd4",
          "birth_date" => "1980-10-17",
          "gender" => "MALE",
          "social_security_number" => "512-17-4444",
          "hired_date" => "2015-04-18",
          "job_title" => "Sales Manger",
          "pay_schedule_id" => "50847c11-bee9-0132-2f6e-56847afe9799",
          "address" => {
            "billing" => {
              "line1" => "342 De Carlo Ave",
              "city" => "Richmond",
              "region" => "CA",
              "postal_code" => "94801",
              "country" => "United States"
            },
            "shipping" => {
              "line1" => "342 De Carlo Ave",
              "city" => "Richmond",
              "region" => "CA",
              "postal_code" => "94801",
              "country" => "United States"
            }
          },
          "email" => {
            "address" => "ben.wilson@test.com"
          },
          "phone" => {
            "landline" => "408-123-4567"
          },
          "employee_salaries" => [
            {
              "id" => "5523221d0202cb423200d888",
              "type" => "HOURLY",
              "name" => "Regular Hours",
              "currency" => "USD",
              "hourly_rate" => 32.5,
              "hours_per_week" => 40,
              "pay_item_id" => "54fc6fa1-bee9-0132-2f72-56847afe9799"
            },
            {
              "id" => "6623221d0202cb423200d8ef",
              "type" => "SALARY",
              "frequency" => "TWICEAMONTH",
              "name" => "Bonus",
              "currency" => "USD",
              "hourly_rate" => 10.5,
              "hours_per_week" => 40,
              "annual_salary" => 10000,
              "pay_item_id" => "54fc6fa1-bee9-0132-2f72-56847afe9799"
            }
          ],
          "work_locations" => [
            {
              "id" => "561ef5f30202cbfc3300236b",
              "work_location_id" => "398cb8f1-5503-0133-9e89-56847afe9799",
              "role" => "Responsible",
              "description" => "Responsible for the San Francisco office",
              "primary" => true
            },
            {
              "id" => "561ef5f30202cbfc3300236d",
              "work_location_id" => "3990d7a0-5503-0133-9e8f-56847afe9799",
              "role" => "Manager"
            }
          ],
          "updated_at" => "2015-04-22T00:58:39.000Z",
          "created_at" => "2015-04-07T00:17:33.199Z"
        }
      }

      let(:cc_contact) {
        {
          :addresses => [
            {
              :line1=>"342 De Carlo Ave", 
              :city=>"Richmond", 
              :state=>"CA", 
              :postal_code=>"94801", 
              :country_code=>"US",
              :address_type=>"BUSINESS"
            }
          ],
          :email_addresses => [{:email_address=>"ben.wilson@test.com"}],
          :first_name => "Benjamin",
          :job_title => "Sales Manger",
          :last_name => "Wilson",
          :work_phone => "408-123-4567",
        }
      }

      before {
        subject.instance_variable_set(:@lists, lists)
      }

      context 'when no specific list' do
        let(:lists) {[{'id' => 'id', 'name' => 'Main list'}]}
        it { expect(subject.map_to_external(connec_employee, nil)).to eql(cc_contact.merge(lists: [{id: 'id'}])) }
      end

      context 'when employee list' do
        let(:employee_list) { {'id' => 'emp', 'name' => 'Employee'} }
        let(:lists) {[{'id' => 'id', 'name' => 'Main list'}, employee_list]}
        it { expect(subject.map_to_external(connec_employee, nil)).to eql(cc_contact.merge(lists: [{id: employee_list['id']}])) }
      end
    end
  end
end
