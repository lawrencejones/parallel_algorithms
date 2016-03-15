require_relative './mesh_matrix_helpers'
require_relative '../networks/mesh'

module MatrixAlgorithms
  class MeshMatrixVectorMultiply < Networks::Mesh
    include MeshMatrixHelpers

    def initialize(no_of_processes, m, vector)
      super(no_of_processes) do |_network, process|
        # One-to-all up column
        if diagonal?(process) && process.state.key?(:seed)
          seed = process.state.delete(:seed)
          all_in_column = (0..root_p - 1).map { |i| i * root_p + process.i % root_p }

          all_in_column.each { |dst| process.send_to(dst, seed) }
          next
        end

        if process.in.any? && process.state[:vector].nil?
          process.in.map { |(_, vs)| process.state[:vector] = vs }
          process.state[:ith_result] = process.state[:matrix] * process.state[:vector]

          row_index = (process.i / root_p).floor
          diagonal = row_index * root_p + row_index

          process.send_to(diagonal, process.state[:ith_result]) unless diagonal?(process)
          next
        end

        if process.state.key?(:ith_result) && diagonal?(process)
          process.state[:result] ||= process.in.
            reduce(process.state[:ith_result]) do |a, (_, ith_result)|
              a + ith_result
            end
        end
      end

      @m = m
      @vector = vector

      ps.each { |p| p.state[:matrix] = process_minor(p.i) }
      vector.each_slice(vector.count / root_p).each_with_index do |vs, i|
        ps[i * root_p + i].state[:seed] = Matrix[vs].t
      end
    end

    attr_reader :vector

    def global_result_vector
      all_results = ps.map { |p| p.state[:result].to_a }.compact.flatten
      Matrix[all_results].t
    end
  end
end
