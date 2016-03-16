require 'terminal-table'

module MatrixAlgorithms
  module MeshMatrixHelpers
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

    def ij_to_process(i, j)
      base_pi = n * (i / block_width).floor
      base_pi + (j / block_width).floor % n
    end

    def block_width
      Math.sqrt(m.count / p).to_i
    end

    def root_p
      Math.sqrt(p).floor
    end

    def diagonal?(p)
      row_index = (p.i / root_p).floor
      row_index == p.i % root_p
    end

    def print_state
      table = Terminal::Table.new do |t|
        for i in 0..root_p - 1
          row = []
          for j in 0..root_p - 1
            p_index = i * root_p + j
            state_string = ps[p_index].state.map { |k, v| "#{k}=#{v}" }.join("\n")
            row << "##{p_index}\n#{state_string}"
          end
          t << row
          t.add_separator unless i == root_p - 1
        end
      end
      puts(table, "\n")
    end
  end
end
