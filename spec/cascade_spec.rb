# frozen_string_literal: true

RSpec.describe Eldr::Cascade do
  let(:not_found)    { ->(_env) { [404, { 'content-type' => 'text/plain' }, ['nope']] } }
  let(:ok)           { ->(_env) { [200, { 'content-type' => 'text/plain' }, ['ok']] } }
  let(:method_not_allowed) { ->(_env) { [405, { 'content-type' => 'text/plain' }, ['no way']] } }

  describe 'NOTFOUND' do
    it 'is a 404 with lowercase content-type header and an empty body' do
      expect(described_class::NOTFOUND[0]).to eq(404)
      expect(described_class::NOTFOUND[1]).to eq('content-type' => 'text/plain')
      expect(described_class::NOTFOUND[2]).to eq([])
    end
  end

  describe '#initialize' do
    it 'adds every given app' do
      cascade = described_class.new([not_found, ok])
      expect(cascade.apps.length).to eq(2)
    end

    it 'defaults to catching 404 and 405' do
      cascade = described_class.new([method_not_allowed, ok])
      expect(cascade.call({}).first).to eq(200)
    end

    it 'accepts a custom list of statuses to catch' do
      cascade = described_class.new([ok], [418])
      # ok returns 200 which is not caught, so the first app's 200 is returned
      expect(cascade.call({}).first).to eq(200)
    end
  end

  describe '#call' do
    it 'returns NOTFOUND when there are no apps' do
      cascade = described_class.new([])
      expect(cascade.call({})).to eq(described_class::NOTFOUND)
    end

    it 'returns the final caught response when every app is caught' do
      cascade = described_class.new([not_found, not_found])
      result = cascade.call({})
      expect(result[0]).to eq(404)
      expect(result[2]).to eq(['nope'])
    end

    it 'returns the first non-caught response' do
      cascade = described_class.new([not_found, ok])
      result = cascade.call({})
      expect(result[0]).to eq(200)
      expect(result[2]).to eq(['ok'])
    end

    it 'stops iterating once a non-caught status is found' do
      visited = 0
      second = lambda { |_env|
        visited += 1
        [200, {}, ['x']]
      }
      cascade = described_class.new([not_found, second, not_found])
      cascade.call({})
      expect(visited).to eq(1)
    end

    it 'closes the previous body when moving to the next app' do
      body = Class.new do
        def each = yield 'a'
        attr_reader :closed

        def initialize = @closed = false
        def close = @closed = true
      end.new
      first = ->(_env) { [404, {}, body] }
      cascade = described_class.new([first, ok])
      cascade.call({})
      expect(body.closed).to be(true)
    end
  end

  describe '#add / #<< / #include?' do
    it 'registers an app and reports membership via << and include?' do
      cascade = described_class.new([])
      expect(cascade.include?(ok)).to be(false)
      cascade << ok
      expect(cascade.include?(ok)).to be(true)
      cascade.add(not_found)
      expect(cascade.apps.length).to eq(2)
    end
  end
end
