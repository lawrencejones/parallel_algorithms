require 'rspec/its'
require 'matrix'
require 'matrix_algorithms/mesh_matrix_vector_multiply'

RSpec.describe(MatrixAlgorithms::MeshMatrixVectorMultiply) do
  subject(:multiply) { described_class.new(no_of_processors, m, vector) }

  let(:m) do
    Matrix[[0,  1,  2,  3],
           [4,  5,  6,  7],
           [8,  9, 10, 11],
           [12, 13, 14, 15]]
  end
  let(:vector) { Matrix[[3], [5], [7], [11]] }
  let(:no_of_processors) { 4 }

  describe 'running until complete' do
    before { multiply.run_until { |network| !network.active? } }

    its(:global_result_vector) { is_expected.to eql(m * vector) }
  end
end
