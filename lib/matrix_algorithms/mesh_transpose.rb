require_relative './mesh_matrix_helpers'
require_relative '../networks/mesh'

module MatrixAlgorithms
  class MeshTranspose < Networks::Mesh
    include MeshMatrixHelpers

    def initialize(no_of_processes, m)
      super(no_of_processes) do |_network, process|
        unless process.state[:run?]
          process.state[:matrix] = process.state[:matrix].t
          dst = block_width * (process.i % block_width) + (process.i / block_width).floor
          process.send_to(dst, process.state[:matrix]) unless dst == process.i

          process.state[:run?] = true
        end

        process.in.each { |(_, matrix)| process.state[:matrix] = matrix }
      end

      @m = m
      ps.each { |p| p.state[:matrix] = process_minor(p.i) }
    end
  end
end
