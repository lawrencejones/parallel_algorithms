require 'terminal-table'

module MatrixAlgorithms
  module MeshMatrixHelpers
    # Computes an aggregated matrix from the individual processes
    def gather_matrix(state_key)
      sample_block = ps.first.state[state_key]

      rows = root_p * sample_block.row_size
      columns = root_p * sample_block.column_size

      Matrix.build(rows, columns) do |i, j|
        p_i = (i / sample_block.column_size).floor
        p_j = (j / sample_block.row_size).floor

        p = ps[root_p * p_i + p_j]
        p.state[state_key][i % sample_block.row_size, j % sample_block.row_size]
      end
    end

    # Extracts the block of the matrix that should be mapped to process_i
    def process_minor(process_i, matrix)
      block_width = Math.sqrt(matrix.count / p).floor

      row_index = block_width * (process_i / root_p).floor
      col_index = block_width * (process_i % root_p)

      row_range = Range.new(row_index, row_index + block_width - 1)
      col_range = Range.new(col_index, col_index + block_width - 1)

      matrix.minor(row_range, col_range)
    end

    def diagonal?(process_i)
      row_index = (process_i / root_p).floor
      row_index == process_i % root_p
    end

    def root_p
      Math.sqrt(p).floor
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
