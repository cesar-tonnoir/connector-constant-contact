require 'spec_helper'

describe ConstantContactClient do

  describe 'class methods' do
    subject { ConstantContactClient }

    describe 'create_contact_lists' do
      let!(:organization) { create(:organization, oauth_token: 'token') }

      context 'with no existing lists' do
        before {
          allow_any_instance_of(ConstantContactClient).to receive(:all).and_return([])
        }

        it { 
          expect_any_instance_of(ConstantContactClient).to receive(:create).exactly(4).times
          subject.create_contact_lists(organization)
        }
      end

      context 'with existing lists' do
        before {
          allow_any_instance_of(ConstantContactClient).to receive(:all).and_return([{'name' => 'Customer'}, {'name' => 'Supplier'}])
        }

        it { 
          expect_any_instance_of(ConstantContactClient).to receive(:create).twice
          subject.create_contact_lists(organization)
        }
      end
    end
  end

  describe 'instance methods' do
    let!(:organization) { create(:organization, oauth_token: 'token') }
    subject { Maestrano::Connector::Rails::External.get_client(organization) }
  end
end