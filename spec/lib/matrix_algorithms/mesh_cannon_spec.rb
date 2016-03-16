require 'rspec/its'
require 'matrix'
require 'matrix_algorithms/mesh_cannon'

RSpec.describe(MatrixAlgorithms::MeshCannon) do
  subject(:cannon) { described_class.new(no_of_processors, a, b) }

  let(:a) do
    Matrix[[0,  1,  2,  3],
           [4,  5,  6,  7],
           [8,  9, 10, 11],
           [12, 13, 14, 15]]
  end
  let(:b) do
    Matrix[[3,  5,  7, 11],
           [13, 17, 19, 23],
           [29, 31, 37, 41],
           [43, 47, 53, 59]]
  end
  let(:no_of_processors) { 4 }

  describe 'running until complete' do
    before { cannon.run_until { |network| !network.active? } }

    its(:global_result) { is_expected.to eql(a * b) }
  end
end
