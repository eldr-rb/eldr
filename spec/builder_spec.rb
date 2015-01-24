describe Eldr::Builder do
  describe '#use' do
    it 'supports passing an array of middleware' do
      builder = Eldr::Builder.new
      builder.use Class.new
      builder_2 = Eldr::Builder.new
      builder_2.use builder.middleware
      expect(builder_2.middleware).to eq(builder.middleware)
    end
  end
end
