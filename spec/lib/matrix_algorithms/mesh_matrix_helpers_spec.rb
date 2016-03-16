require 'matrix'
require 'networks/mesh'
require 'matrix_algorithms/mesh_matrix_helpers'

RSpec.describe(MatrixAlgorithms::MeshMatrixHelpers) do
  subject(:network) do
    Class.new(Networks::Mesh) { include MatrixAlgorithms::MeshMatrixHelpers }.
      new(no_of_processes)
  end

  let(:no_of_processes) { 4 }
  let(:matrix) do
    Matrix[[0,  1,  2,  3],
           [4,  5,  6,  7],
           [8,  9, 10, 11],
           [12, 13, 14, 15]]
  end

  describe '.diagonal?' do
    it 'is true if process is on matrix diagonal' do
      expect(network.diagonal?(3)).to be(true)
    end

    it 'is false otherwise' do
      expect(network.diagonal?(1)).to be(false)
    end
  end

  describe '.gather_matrix' do
    before do
      network.ps[0].state[:m] = matrix.minor(0..1, 0..1)
      network.ps[1].state[:m] = matrix.minor(0..1, 2..3)
      network.ps[2].state[:m] = matrix.minor(2..3, 0..1)
      network.ps[3].state[:m] = matrix.minor(2..3, 2..3)
    end

    it 'aggregates process state matrices' do
      expect(network.gather_matrix(:m)).to eql(matrix)
    end
  end

  describe '.process_minor' do
    it 'extracts in left-to-right order', :aggregate_failures do
      expect(network.process_minor(0, matrix)).to eql(Matrix[[0,1],[4,5]])
      expect(network.process_minor(1, matrix)).to eql(Matrix[[2,3],[6,7]])
      expect(network.process_minor(2, matrix)).to eql(Matrix[[8,9],[12,13]])
      expect(network.process_minor(3, matrix)).to eql(Matrix[[10,11],[14,15]])
    end
  end
end
