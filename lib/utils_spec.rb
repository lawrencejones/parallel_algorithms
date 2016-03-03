require 'utils'

RSpec.describe(Utils) do
  before do
    allow(Utils).
      to receive(:dictionary).
      and_return(Set.new(%w(sheep dog cat mouse)))
  end

  describe('.stream_cipher') do
    let(:plain_text) { 'white  , space ' }

    it 'preserves whitespace and punctuation' do
      Utils.stream_cipher(plain_text) { |char, _i| char }.tap do |result|
        expect(result).to eql(plain_text)
      end
    end

    it 'provides cipher with correct indexes' do
      indexes = []
      Utils.stream_cipher(plain_text) { |_char, i| indexes.push(i) }

      expect(indexes).to match_array(*[0..9])
    end

    it 'computes next character using cipher' do
      Utils.stream_cipher(plain_text) { |_char, _i| 'a' }.tap do |result|
        expect(result).to eql('aaaaa  , aaaaa ')
      end
    end
  end

  describe('.pct_in_dictionary') do
    it 'calculates percentage as a float' do
      expect(Utils.pct_in_dictionary('sheep dog called mike')).to be(0.5)
    end

    it 'ignores case' do
      expect(Utils.pct_in_dictionary('ShEeP DoG called mike')).to be(0.5)
    end

    it 'ignores punctuation' do
      expect(Utils.pct_in_dictionary('sheep dog, called mike')).to be(0.5)
    end
  end
end
