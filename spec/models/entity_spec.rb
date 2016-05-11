require 'spec_helper'

describe Maestrano::Connector::Rails::Entity do

  describe 'class methods' do
    subject { Maestrano::Connector::Rails::Entity }

    it { expect(subject.id_from_external_entity_hash({'id' => '123'})).to eql('123') }
    it { expect(subject.last_update_date_from_external_entity_hash({'modified_date' => "2016-05-10T14:40:43.000Z"})).to eql("2016-05-10T14:40:43.000Z".to_time) }
    it { expect(subject.external_singleton?).to be false }
    it { expect(subject.no_date_filtering?).to be false }
  end

  describe 'instance methods' do
    subject { Maestrano::Connector::Rails::Entity.new }
    let!(:organization) { create(:organization, oauth_token: 'token') }
    let(:client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:external_entity_name) { 'Contact' }

    describe 'get_external_entities' do
      let(:last_synchronization) { create(:synchronization, organization: organization, updated_at: 2.days.ago) }
      let(:opts) { {} }
      before { allow(subject.class).to receive(:external_entity_name).and_return(external_entity_name) }

      context 'cant read external' do
        before { allow(subject.class).to receive(:can_read_external?).and_return false }
        it { expect(subject.get_external_entities(client, last_synchronization, organization, opts)).to eql([]) }
      end

      describe 'full syncs' do
        def does_a_full_sync
          expect(client).to receive(:all).with(external_entity_name, false).and_return([])
          subject.get_external_entities(client, last_synchronization, organization, opts)
        end

        context 'with opts' do
          let(:opts) { {full_sync: true} }
          it { does_a_full_sync }
        end

        context 'with no last_synchronization' do
          let(:last_synchronization) { nil }
          it { does_a_full_sync }
        end

        context 'with no_date_filtering' do
          before { allow(subject.class).to receive(:no_date_filtering?).and_return(true) }
          it { does_a_full_sync }
        end
      end

      describe 'partial sync' do
        it 'calls all with a timestamps' do
          expect(client).to receive(:all).with(external_entity_name, false, last_synchronization.updated_at).and_return([])
          subject.get_external_entities(client, last_synchronization, organization, opts)
        end
      end

      it 'returns the result' do
        allow(client).to receive(:all).and_return([{'id' => '12'}])
        expect(subject.get_external_entities(client, last_synchronization, organization, opts)).to eql([{'id' => '12'}])
      end
    end

    describe 'create_external_entity' do
      let(:entity) { {first_name: 'Lily'} }
      it 'calls create' do
        expect(client).to receive(:create).with(external_entity_name, entity).and_return('123')
        subject.create_external_entity(client, entity, external_entity_name, organization)
      end

      it 'returns the id' do
        allow(client).to receive(:create).and_return('123')
        expect(subject.create_external_entity(client, entity, external_entity_name, organization)).to eql('123')
      end
    end

    describe 'update_external_entity' do
      let(:entity) { {first_name: 'Lily'} }
      let(:id) { '123' }

      it 'calls update' do
        expect(client).to receive(:update).with(external_entity_name, entity, id).and_return({})
        subject.update_external_entity(client, entity, id, external_entity_name, organization)
      end
    end

  end
end