require_relative './base'

module Networks
  # 2D mesh of processes with connections to neighbours and no wraparound.
  # Example processor indexing...
  #
  #                   | 0, 1, 2 |
  #   Mesh.new(9) =>  | 3, 4, 5 |
  #                   | 6, 7, 8 |
  #
  class Mesh < Base
    def n
      @n ||= Math.sqrt(ps.size).to_i
    end

    def hops_between(src, dst)
      rows = (src - dst).abs % n
      cols = ((src - dst).abs / n).floor

      rows + cols
    end
  end
end
