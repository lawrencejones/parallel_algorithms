require_relative '../networks/mesh'

module MatrixAlgorithms
  class MeshTranspose
    def initialize(m, no_of_processes)
      @m = m
      @mesh = build_mesh(no_of_processes)
      @mesh.ps.each { |p| init_process(p) }
    end

    def run
      mesh.run_until { |network| !network.active? }
      global_matrix
    end

    # Computes the global matrix from the individual process minors
    def global_matrix
      Matrix.build(m.row_size, m.column_size) do |i, j|
        p = mesh.ps[ij_to_process(i, j)]
        p.state[:matrix][i % block_width, j % block_width]
      end
    end

    attr_reader :m, :mesh

    private

    def build_mesh(no_of_processes)
      Networks::Mesh.new(no_of_processes) do |_network, process|
        unless process.state[:run?]
          process.state[:matrix] = process.state[:matrix].t
          dst = block_width * (process.i % block_width) + (process.i / block_width).floor
          process.send(dst, process.state[:matrix]) unless dst == process.i

          process.state[:run?] = true
        end

        process.in.each { |(_, matrix)| process.state[:matrix] = matrix }
      end
    end

    def init_process(p)
      p.state[:matrix] = process_minor(p.i)
    end

    def process_minor(pi)
      row_index = pi / Math.sqrt(mesh.ps.size).to_i
      col_index = pi % Math.sqrt(mesh.ps.size).to_i

      row_range = Range.new(block_width * row_index, block_width * (row_index + 1) - 1)
      col_range = Range.new(block_width * col_index, block_width * (col_index + 1) - 1)

      m.minor(row_range, col_range)
    end

    def ij_to_process(i, j)
      base_pi = Math.sqrt(mesh.ps.size).floor * (i / block_width).floor
      base_pi + (j / block_width).floor % Math.sqrt(mesh.ps.size).floor
    end

    def block_width
      Math.sqrt(m.count / mesh.ps.size).to_i
    end
  end
end
