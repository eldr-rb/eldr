# frozen_string_literal: true

class CatsHandler
  def index(_env)
    'cats'
  end
end

class ActionHandler
  def call(_env)
    'action handled!'
  end
end

RSpec.describe Eldr::Route do
  describe '.new' do
    it 'returns a new instance' do
      expect(described_class.new).to be_instance_of described_class
    end

    it 'takes options and sets them' do
      route = described_class.new(name: :cats)
      expect(route.name).to eq(:cats)
    end
  end

  describe '#create_handler' do
    context 'rails style handler' do
      let(:route) do
        described_class.new(handler: 'CatsHandler#index')
      end

      it 'wraps the handler in a proc' do
        expect(route.create_handler('CatsHandler#index')).to be_a Proc
      end
    end
  end

  describe '#params' do
    let(:route) do
      described_class.new(path: '/cats/:id')
    end

    it 'returns splat parameters for a path string' do
      expect(route.params('/cats/omalley')['id']).to eq('omalley')
    end

    it 'returns an empty hash when the pattern does not match' do
      expect(route.params('/dogs/x')).to eq({})
    end
  end

  describe '#create_handler with an unknown constant' do
    it 'raises NameError when the controller does not exist' do
      route = described_class.new(handler: 'NoSuchController#index')
      expect { route.call({}) }.to raise_error(NameError)
    end
  end

  describe '#call' do
    context 'when #app is nil' do
      let(:route) do
        described_class.new(handler: proc { 'cats' })
      end

      it "still calls a route's handler" do
        expect(route.call({})).to eq('cats')
      end
    end

    context 'when handler is a proc' do
      let(:route) do
        described_class.new(handler: proc { @cats })
      end

      let(:app) do
        class Bob < Eldr::App
          attr_accessor :cats
        end
        bob = Bob._new
        bob.cats = 'cats'
        bob
      end

      it 'calls it in the scope of the app instances and returns the response' do
        expect(route.call({}, app: app)).to eq('cats')
      end
    end

    context 'when handler is a string' do
      let(:route) do
        described_class.new(handler: 'CatsHandler#index')
      end

      it 'splits string into a controller name/method; and then calls it with env' do
        expect(route.call({})).to eq('cats')
      end
    end

    context 'when handler is an object' do
      let(:route) do
        described_class.new(handler: ActionHandler.new)
      end

      it 'calla the #call method of the object' do
        expect(route.call({})).to eq('action handled!')
      end
    end

    context 'when there are before filters' do
      let(:route) do
        described_class.new(handler: proc { 'cats' })
      end

      it 'calls the before filters' do
        called = false
        route.before_filters << proc { called = true }
        route.call({})
        expect(called).to be(true)
      end
    end

    context 'when there are after filters' do
      let(:route) do
        described_class.new(handler: proc { 'cats' })
      end

      it 'calls the before filters' do
        called = false
        route.after_filters << proc { called = true }
        route.call({})
        expect(called).to be(true)
      end
    end
  end
end
