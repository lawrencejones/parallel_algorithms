require 'rspec/its'
require 'matrix'
require 'matrix_algorithms/mesh_transpose'

RSpec.describe(MatrixAlgorithms::MeshTranspose) do
  subject(:transpose) { described_class.new(no_of_processors, m) }

  let(:m) do
    Matrix[[0,  1,  2,  3],
           [4,  5,  6,  7],
           [8,  9, 10, 11],
           [12, 13, 14, 15]]
  end

  let(:m) { Matrix.build(4, 4) { |r, c| r * 4 + c } }
  let(:no_of_processors) { 4 }

  describe 'running until complete' do
    before { transpose.run_until { |network| !network.active? } }

    its(:global_matrix) { is_expected.to eql(m.t) }

    it 'costs ts + (n^2/p)*tw + 2*(p^.5 - 1)*th' do
      expect(transpose.cost).
        to eql(ts: 1,
               th: 2 * (Math.sqrt(no_of_processors).floor - 1),
               tw: (m.count / no_of_processors).floor)
    end
  end
end
