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
    let!(:organization) { create(:organization, oauth_token: 'token') }
    let(:connec_client) { nil }
    let(:external_client) { Maestrano::Connector::Rails::External.get_client(organization) }
    let(:opts) { {} }
    subject { Maestrano::Connector::Rails::Entity.new(organization, connec_client, external_client, opts) }
    let(:external_entity_name) { 'Contact' }

    describe 'get_external_entities' do
      let(:last_synchronization) { create(:synchronization, organization: organization, updated_at: 2.days.ago) }
      let(:opts) { {} }

      describe 'full syncs' do
        def does_a_full_sync
          expect(external_client).to receive(:all).with(external_entity_name, false).and_return([])
          subject.get_external_entities(external_entity_name, last_synchronization && last_synchronization.updated_at)
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
          expect(external_client).to receive(:all).with(external_entity_name, false, last_synchronization.updated_at).and_return([])
          subject.get_external_entities(external_entity_name, last_synchronization.updated_at)
        end
      end

      it 'returns the result' do
        allow(external_client).to receive(:all).and_return([{'id' => '12'}])
        expect(subject.get_external_entities(external_entity_name, last_synchronization.updated_at)).to eql([{'id' => '12'}])
      end
    end

    describe 'create_external_entity' do
      let(:entity) { {first_name: 'Lily'} }
      it 'calls create' do
        expect(external_client).to receive(:create).with(external_entity_name, entity).and_return({'id' => '123'})
        subject.create_external_entity(entity, external_entity_name)
      end

      it 'returns the entity' do
        allow(external_client).to receive(:create).and_return({'id' => '123'})
        expect(subject.create_external_entity(entity, external_entity_name)).to eql({'id' => '123'})
      end
    end

    describe 'update_external_entity' do
      let(:entity) { {first_name: 'Lily'} }
      let(:id) { '123' }

      it 'calls update' do
        expect(external_client).to receive(:update).with(external_entity_name, entity, id).and_return({})
        subject.update_external_entity(entity, id, external_entity_name)
      end
    end

  end
end