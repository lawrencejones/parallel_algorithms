require 'matrix'
require 'matrix_algorithms/mesh_transpose'

RSpec.describe(MatrixAlgorithms::MeshTranspose) do
  subject(:transpose) { described_class.new(m, no_of_processors) }

  let(:m) do
    Matrix[[0,  1,  2,  3],
           [4,  5,  6,  7],
           [8,  9, 10, 11],
           [12, 13, 14, 15]]
  end

  let(:m) { Matrix.build(4, 4) { |r, c| r * 4 + c } }
  let(:no_of_processors) { 4 }
  let(:mesh) { transpose.mesh }

  describe '.global_matrix' do
    it 'computes global matrix from all process minors' do
      # Use the fact that initially, the global will be the input
      expect(transpose.global_matrix).to eql(m)
    end
  end

  describe '.ij_to_process' do
    it 'maps to each process id' do
      [[1, 1], [0, 2], [3, 0], [2, 3]].each_with_index do |(i, j), pid|
        expect(transpose.send(:ij_to_process, i, j)).to equal(pid.to_s.to_i)
      end
    end
  end

  describe '.minor_for_process' do
    it 'computes top left' do
      expect(transpose.send(:process_minor, 0)).
        to eql(Matrix[[0, 1], [4, 5]])
    end

    it 'computes bottom left' do
      expect(transpose.send(:process_minor, 2)).
        to eql(Matrix[[8, 9], [12, 13]])
    end
  end

  describe '.run' do
    subject!(:t) { transpose.run }

    it { is_expected.to eql(m.t) }

    it 'runs in ts + (n^2/p)*tw + 2*(p^.5 - 1)*th' do
      expect(mesh.cost).
        to eql(ts: 1,
               th: 2 * (Math.sqrt(no_of_processors).floor - 1),
               tw: (m.count / no_of_processors).floor)
    end
  end
end
