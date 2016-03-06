require 'matrix'
require 'matrix_algorithms/mesh_transpose'

RSpec.describe(MatrixAlgorithms::MeshTranspose) do
  subject(:transpose) { described_class.new(m, no_of_processors) }

  # rubocop:disable all
  let(:m) do
    Matrix[[ 0,  1,  2,  3],
           [ 4,  5,  6,  7],
           [ 8,  9, 10, 11],
           [12, 13, 14, 15]]
  end
  # rubocop:enable all

  let(:m) { Matrix.build(4, 4) { |r, c| r * 4 + c } }
  let(:no_of_processors) { 4 }

  describe '.global_matrix' do
    it 'computes global matrix from all process minors' do
      # Use the fact that initially, the global will be the input
      expect(transpose.global_matrix).to eql(m)
    end
  end

  describe '.ij_to_process' do
    it 'maps to each process id' do
      { '0': [1, 1], '1': [0, 2], '2': [3, 0], '3': [2, 3] }.each do |pid, (i,j)|
        expect(transpose.send(:ij_to_process, i, j)).to equal(pid.to_s.to_i)
      end
    end
  end

  describe '.minor_for_process' do
    it 'computes top left' do
      expect(transpose.send(:process_minor, 0)).
        to eql(Matrix[[0,1],[4,5]])
    end

    it 'computes bottom left' do
      expect(transpose.send(:process_minor, 2)).
        to eql(Matrix[[8,9],[12,13]])
    end
  end

  describe '.t' do
    subject(:t) { transpose.t }

    it { is_expected.to eql(m.t) }
  end
end
