describe Eldr::Configuration do
  describe '#initialize' do
    it 'sets defaults' do
      expect(Eldr::Configuration.new().lock).to eq(false)
    end
  end

  describe '#set' do
    let(:config) { Eldr::Configuration.new }

    it 'sets a configuration value in #table' do
      config.set(:bob, 'what about him?')
      expect(config.bob).to eq('what about him?')
    end
  end

  describe '#method_missing' do
    let(:config) { Eldr::Configuration.new }

    it 'returns a value from #table' do
      config.set(:bob, 'what about him?')
      expect(config.bob).to eq('what about him?')
    end

    it 'returns nil as a default' do
      expect(config.franklin).to eq(nil)
    end
  end
end
