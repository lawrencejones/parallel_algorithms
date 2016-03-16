require_relative './mesh_matrix_helpers'
require_relative '../networks/mesh'

module MatrixAlgorithms
  class MeshCannon < Networks::Mesh
    include MeshMatrixHelpers

    def initialize(no_of_processes, global_a, global_b)
      super(no_of_processes) do |_network, process|
        next if process.state[:step] < 0
        state = process.state
        state[:step] -= 1

        # Run initial shifting of blocks
        if state[:step] == root_p
          row_index = (process.i / root_p).floor
          column_index = process.i % root_p

          process.send_to(neighbour(process.i, :left, by: row_index), state[:a])
          process.send_to(neighbour(process.i, :up, by: column_index), state[:b])

        # Now start shift-multiplying
        elsif state[:step] >= 0
          from_row = process.in.
            find { |(src)| (src / root_p).floor == (process.i / root_p).floor }
          from_column = process.in.
            find { |(src)| (src % root_p) == (process.i % root_p) }

          unless (from_row[0] == process.i) && (from_column[0] == process.i)
            state[:a] = from_row[1]
            state[:b] = from_column[1]
          end

          state[:result] += state[:a] * state[:b]

          process.send_to(neighbour(process.i, :left), state[:a])
          process.send_to(neighbour(process.i, :up), state[:b])
        end
      end

      ps.each do |p|
        p.state[:a] = process_minor(p.i, global_a)
        p.state[:b] = process_minor(p.i, global_b)
        p.state[:result] = Matrix.zero(p.state[:a].row_size, p.state[:b].column_size)
        p.state[:step] = root_p + 1
      end
    end

    def global_result
      gather_matrix(:result)
    end

    def neighbour(process_i, direction, by: 1)
      return process_i if by < 1
      neighbour(direct_neighbour(process_i, direction), direction, by: by - 1)
    end

    def direct_neighbour(process_i, direction)
      case direction
      when :up    then (process_i - n + p) % p
      when :down  then (process_i + n) % p
      when :left  then process_i - (process_i % n) + ((process_i - 1 + n) % n)
      when :right then process_i - (process_i % n) + ((process_i + 1) % n)
      end
    end
  end
end
