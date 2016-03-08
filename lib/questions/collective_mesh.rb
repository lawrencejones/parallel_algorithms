require_relative '../networks/mesh'

module Questions
  # Implementation of the algorithm from Tutorial 4 - Collective Communications.
  # Behaves as MPI_Allgather, where every node collects each value from every other node.
  class CollectiveMesh < Networks::Mesh
    def initialize(*args)
      super(*args) do |_network, process|
        vector = process.state[:vector]
        process.in.each { |(_, msg)| vector.push(*msg) }

        if vector.size < n
          process.send(right(process.i), vector.last(1))
          next
        end

        if vector.size.between?(n, p - n)
          process.send(down(process.i), vector.last(n))
        end
      end

      ps.each_with_index { |p, i| p.state[:vector] = [i] }
    end

    def left(i)
      i - (i % n) + ((i - 1 + n) % n)
    end

    def right(i)
      i - (i % n) + ((i + 1) % n)
    end

    def up(i)
      (i - n + p) % p
    end

    def down(i)
      (i + n) % p
    end
  end
end
