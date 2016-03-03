require 'symmetric/vigenere_cipher'

RSpec.describe(VigenereCipher) do
  subject(:cipher) { described_class.new(key) }
  let(:key) { 'crypto' }

  # Uses a Vigenere cipher with key 'crypto'
  let(:plain_text) { load_fixture('sample.vigenere.plaintext') }
  let(:cipher_text)  { load_fixture('sample.vigenere.encrypted') }

  describe('.encode') do
    it 'generates ciphertext' do
      expect(cipher.encode('thisisatestmessage')).
        to eql('vyghbgckchmagjqpzs')
    end

    it 'encodes fixture' do
      expect(cipher.encode(plain_text)).to eql(cipher_text)
    end
  end
end
