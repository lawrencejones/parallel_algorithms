require 'networks/mesh'

RSpec.describe(Networks::Mesh) do
  subject(:mesh) { described_class.new(no_of_processes) { |_, _| nil } }

  describe '.hops_between' do
    let(:no_of_processes) { 9 }

    it 'computes same row hops' do
      expect(mesh.hops_between(2, 0)).to equal(2)
    end

    it 'computes same column hops' do
      expect(mesh.hops_between(1, 7)).to equal(2)
    end

    it 'computes diagonal hops' do
      expect(mesh.hops_between(6, 1)).to equal(3)
    end
  end
end
