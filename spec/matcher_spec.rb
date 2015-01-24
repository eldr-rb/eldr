describe Eldr::Matcher do
  describe '#match' do
    let(:matcher) { Eldr::Matcher.new('/cats/:id') }

    context 'when pattern matches' do
      it 'returns MatchData' do
        expect(matcher.match('/cats/bob')).to be_instance_of MatchData
      end

      it 'returns the splats' do
        expect(matcher.match('/cats/bob')[:id]).to eq('bob')
      end
    end

    context 'when pattern does not match' do
      it 'returns nil' do
        expect(matcher.match('/dogs/bob')).to be_nil
      end
    end
  end
end
