# frozen_string_literal: true

RSpec.describe Eldr::Configuration do
  describe '#initialize' do
    it 'sets defaults' do
      expect(described_class.new.lock).to be(false)
    end
  end

  describe '#set' do
    let(:config) { described_class.new }

    it 'sets a configuration value in #table' do
      config.set(:bob, 'what about him?')
      expect(config.bob).to eq('what about him?')
    end
  end

  describe '#method_missing' do
    let(:config) { described_class.new }

    it 'returns a value from #table' do
      config.set(:bob, 'what about him?')
      expect(config.bob).to eq('what about him?')
    end

    it 'returns nil as a default' do
      expect(config.franklin).to be_nil
    end

    it 'acts as a setter when an argument is given' do
      config.lock = true
      expect(config.lock).to be(true)
      expect(config.table[:lock]).to be(true)
    end

    it 'strips a trailing ? when reading' do
      config.set(:open, true)
      expect(config.open?).to be(true)
    end
  end

  describe '#respond_to?' do
    let(:config) { described_class.new }

    it 'reports true for known readers and setters' do
      config.set(:bob, 'x')
      expect(config.respond_to?(:bob)).to be(true)
      expect(config.respond_to?(:bob=)).to be(true)
    end

    it 'reports false for unknown readers' do
      expect(config.respond_to?(:totally_unknown)).to be(false)
    end
  end

  describe '#merge!' do
    let(:config) { described_class.new }

    it 'merges a plain hash' do
      config.merge!(bob: 'x')
      expect(config.bob).to eq('x')
    end

    it 'merges another Configuration instance by reading its table' do
      other = described_class.new
      other.set(:cats, 'meow')
      config.merge!(other)
      expect(config.cats).to eq('meow')
    end

    it 'preserves existing defaults' do
      config.merge!(bob: 'x')
      expect(config.lock).to be(false)
    end
  end
end
