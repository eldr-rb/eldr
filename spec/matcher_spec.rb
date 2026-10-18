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
    it 'raises ArgumentError for paths that are neither String nor Regexp' do
      expect { described_class.new(:cats) }
        .to raise_error(ArgumentError, /unsupported path type: Symbol \(expected String or Regexp\)/)
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

  describe '#params' do
    context 'with a parameterized pattern' do
      let(:matcher) { described_class.new('/cats/:id') }

      it 'extracts the named captures' do
        expect(matcher.params('/cats/bob')).to eq('id' => 'bob')
      end

      it 'returns an empty hash when the pattern does not match' do
        expect(matcher.params('/dogs/bob')).to eq({})
      end
    end

    context 'with a literal pattern' do
      let(:matcher) { described_class.new('/static') }

      it 'returns an empty hash without matching' do
        expect(matcher.params('/static')).to eq({})
      end
    end
  end
end
