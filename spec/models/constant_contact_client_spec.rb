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
    let(:api_key) { 'api_key' }
    let(:token) { 'token' }
    let(:headers) { {'Authorization' => token, 'Content-Type' => 'application/json'} }
    subject { ConstantContactClient.new(api_key, token) }

    describe 'initialize' do
      it 'assigns instance variables' do
        subject
        expect(subject.instance_variable_get(:@api_key)).to eql(api_key)
        expect(subject.instance_variable_get(:@headers)).to eql(headers)
      end
    end

    describe 'all' do
      context 'without modified_since' do
        it 'send a get with the api_key' do
          expect(subject.class).to receive(:get).with("#{subject.send(:endpoint, 'Contact')}?api_key=#{api_key}", headers: headers).and_return(ActionDispatch::Response.new(200, {}, {'results' => []}.to_json, {}))
          subject.all('Contact', false)
        end
      end

      context 'with modified_since' do
        let(:modified_since) { '01/01/2016'.to_time }
        it 'send a get with the api_key and modified_since' do
          query_params = {api_key: api_key, modified_since: modified_since.iso8601}
          expect(subject.class).to receive(:get).with("#{subject.send(:endpoint, 'Contact')}?#{query_params.to_query}", headers: headers).and_return(ActionDispatch::Response.new(200, {}, {'results' => []}.to_json, {}))
          subject.all('Contact', false, modified_since)
        end
      end

      describe 'when singleton' do
        let(:body) { {'some_field' => 223} }
        it 'returns the response body in an array' do
          allow(subject.class).to receive(:get).and_return(ActionDispatch::Response.new(200, {}, body.to_json, {}))
          expect(subject.all('Contact', true)).to eql([body])
        end
      end

      describe 'when response is an array' do
        let(:body) { [{'some_field' => 223}] }
        it 'returns the array' do
          allow(subject.class).to receive(:get).and_return(ActionDispatch::Response.new(200, {}, body.to_json, {}))
          expect(subject.all('Contact', false)).to eql(body)
        end
      end

      describe 'when response is an hash' do
        let(:results) { [{'some_field' => 223}] }

        context 'without pagination' do
          it 'returns the results' do
            allow(subject.class).to receive(:get).and_return(ActionDispatch::Response.new(200, {}, {'results' => results}.to_json, {}))
            expect(subject.all('Contact', false)).to eql(results)
          end
        end

        context 'with pagination' do
          let(:next_link) { '/v2/somewhere/?next_link=23qwe213' }
          before {
            allow(subject.class).to receive(:get).and_return(ActionDispatch::Response.new(200, {}, {'meta' => {'pagination' => {'next_link' => next_link}}, 'results' => results}.to_json, {}), ActionDispatch::Response.new(200, {}, {'results' => results}.to_json, {}))
          }

          it 'calls get with the next link' do
            expect(subject.class).to receive(:get).twice
            subject.all('Contact', false)
          end

          it 'returns both the results' do
            expect(subject.all('Contact', false)).to eql(results << results.first)
          end
        end
      end
      
      describe 'failures' do
        let(:body) { nil }
        let(:response) { ActionDispatch::Response.new(200, {}, body.to_json, {}) }
        before { allow(subject.class).to receive(:get).and_return(response) }

        context 'when unknow entity' do
          it {expect{ subject.all('Not an entity', false) }.to raise_error(RuntimeError)}
        end

        context 'when no response' do
          let(:response) { nil }
          it {expect{ subject.all('Contact', false) }.to raise_error(RuntimeError)}
        end

        context 'when empty response' do
          let(:body) { nil }
          it {expect{ subject.all('Contact', false) }.to raise_error(RuntimeError)}
        end

        context 'when hash with no results key' do
          let(:body) { {'key' => 'value'} }
          it {expect{ subject.all('Contact', false) }.to raise_error(RuntimeError)}
        end
      end
    end

    describe 'create' do
      let(:entity) { {first_name: 'John'} }
      let(:body) { {'id' => '123'} }
      let(:response) { ActionDispatch::Response.new(200, {}, body.to_json, {}) }
      before { allow(subject.class).to receive(:post).and_return(response) }

      it 'sends a post' do
        expect(subject.class).to receive(:post).with("#{subject.send(:endpoint, 'Contact')}?api_key=#{api_key}", headers: headers, body: entity.to_json)
        subject.create('Contact', entity)
      end

      it 'returns the id' do
        expect(subject.create('Contact', entity)).to eql('123')
      end

      describe 'failures' do
        context 'when no response' do
          let(:response) { nil }
          it {expect{ subject.create('Contact', entity) }.to raise_error(RuntimeError)}
        end

        context 'when empty response' do
          let(:body) { nil }
          it {expect{ subject.create('Contact', entity) }.to raise_error(RuntimeError)}
        end

        context 'when body is not an hash' do
          let(:body) { [1] }
          it {expect{ subject.create('Contact', entity) }.to raise_error(RuntimeError)}
        end

        context 'when body is an hash with no id key' do
          let(:body) { {'key' => 'value'} }
          it {expect{ subject.create('Contact', entity) }.to raise_error(RuntimeError)}
        end
      end
    end

    describe 'update' do
      let(:entity) { {first_name: 'John'} }
      let(:id) { '123' }
      let(:body) { {'first_name' => 'John'} }
      let(:response) { ActionDispatch::Response.new(200, {}, body.to_json, {}) }
      before { allow(subject.class).to receive(:put).and_return(response) }

      it 'sends a put' do
        expect(subject.class).to receive(:put).with("#{subject.send(:endpoint, 'Contact')}/#{id}?api_key=#{api_key}", headers: headers, body: entity.to_json)
        subject.update('Contact', entity, id)
      end

      describe 'failures' do
        context 'when no response' do
          let(:response) { nil }
          it {expect{ subject.update('Contact', entity, id) }.to raise_error(RuntimeError)}
        end

        context 'when empty response' do
          let(:body) { nil }
          it {expect{ subject.update('Contact', entity, id) }.to raise_error(RuntimeError)}
        end

        context 'when body is not an hash' do
          let(:body) { [{error: 'Bad request'}] }
          it {expect{ subject.update('Contact', entity, id) }.to raise_error(RuntimeError)}
        end
      end
    end
  end
end