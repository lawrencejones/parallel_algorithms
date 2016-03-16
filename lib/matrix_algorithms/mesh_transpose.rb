require_relative './mesh_matrix_helpers'
require_relative '../networks/mesh'

module MatrixAlgorithms
  class MeshTranspose < Networks::Mesh
    include MeshMatrixHelpers

    def initialize(no_of_processes, global_m)
      super(no_of_processes) do |_network, process|
        unless process.state[:sent?]
          matrix = process.state[:matrix]
          dst = matrix.row_size * (process.i % matrix.row_size) +
            (process.i / matrix.column_size).floor
          process.send_to(dst, matrix.t)

          process.state[:sent?] = true
        end

        process.in.each { |(_, m)| process.state[:matrix] = m }
      end

      ps.each { |p| p.state[:matrix] = process_minor(p.i, global_m) }
    end

    def global_matrix
      gather_matrix(:matrix)
    end
  end
end
