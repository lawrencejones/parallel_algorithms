require_relative '../../networks/hypercube'

module Broadcasts
  module Hypercube
    def self.all_to_all_handler(network, process)
      process.state[:step] ||= 0
      stack = process.state[:stack] ||= [process.i]

      unless (_, vals = process.in.first).nil?
        stack.push(*vals).uniq!
      end

      if stack.size < network.ps.size
        next_dst = process.i ^ 2**process.state[:step]
        process.state[:step] += 1
        process.send(next_dst, stack)
      end
    end
  end
end
