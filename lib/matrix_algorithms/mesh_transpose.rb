require_relative '../networks/mesh'

module MatrixAlgorithms
  class MeshTranspose < Networks::Mesh
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

    attr_reader :m

    # Computes the global matrix from the individual process minors
    def global_matrix
      Matrix.build(m.row_size, m.column_size) do |i, j|
        p = ps[ij_to_process(i, j)]
        p.state[:matrix][i % block_width, j % block_width]
      end
    end

    def process_minor(pi)
      row_index = pi / n
      col_index = pi % n

      row_range = Range.new(block_width * row_index, block_width * (row_index + 1) - 1)
      col_range = Range.new(block_width * col_index, block_width * (col_index + 1) - 1)

      m.minor(row_range, col_range)
    end

    private

    def ij_to_process(i, j)
      base_pi = n * (i / block_width).floor
      base_pi + (j / block_width).floor % n
    end

    def block_width
      Math.sqrt(m.count / p).to_i
    end
  end
end
