describe Eldr::Recognizer do
  describe '#call' do
    let(:resp_proc) { proc { [200, {}, ['Hello Bob!']] } }
    subject(:app) do
      bob = Class.new(Eldr::App)
      bob.get '/cats', resp_proc
      bob
    end

    let(:recognizer) { Eldr::Recognizer.new(app.routes) }

    context 'when there are matching routes' do
      let(:env) do
        Rack::MockRequest.env_for('/cats', {:method => :get})
      end

      it 'returns matching routes' do
        expect(recognizer.call(env).length).to eq(1)
      end
    end

    context 'when there are no matching routes' do
      let(:env) do
        Rack::MockRequest.env_for('/no-route-for-me', {:method => :get})
      end

      it 'raises a NotFound error' do
        expect { recognizer.call(env) }.to raise_error
      end
    end
  end
end
