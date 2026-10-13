# frozen_string_literal: true

RSpec.describe Eldr::Matcher do
  describe '#match' do
    let(:matcher) { described_class.new('/cats/:id') }

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

  describe 'regex paths' do
    let(:matcher) { described_class.new(%r{/cats/.*}) }

    it 'matches when the anchored regex matches the full path' do
      expect(matcher.match('/cats/bob')).to be_a(MatchData)
    end

    it 'does not match when the anchored regex does not match the full path' do
      expect(matcher.match('/dogs/bob')).to be_nil
    end
  end

  describe 'unsupported path types' do
    it 'returns a nil handler for paths that are neither String nor Regexp' do
      expect(described_class.new(:cats).handler).to be_nil
    end
  end

  describe 'capture option' do
    let(:matcher) { described_class.new('/cats/:id', capture: { id: /\d+/ }) }

    it 'matches when the capture constraint is satisfied' do
      expect(matcher.match('/cats/123')).to be_a(MatchData)
      expect(matcher.match('/cats/123')[:id]).to eq('123')
    end

    it 'does not match when the capture constraint fails' do
      expect(matcher.match('/cats/abc')).to be_nil
    end
  end
end
