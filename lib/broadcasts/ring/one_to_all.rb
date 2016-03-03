require_relative '../../networks/ring'

module Broadcasts
  module Ring
    def self.one_to_all_handler(network, process)
      # If we received a message then start our own counter
      for src, val in process.in
        prev_step_no = Math.log2(network.hops_between(src, process.i)).to_i
        process.state.merge!(step: prev_step_no, val: val)
      end

      # Now we have the value, forward it to the next node
      unless process.state[:val].nil? || process.state[:step] == 0
        process.state[:step] -= 1
        forward_dst = process.i + 2**process.state[:step]
        forward_dst -= network.ps.size if forward_dst >= network.ps.size

        process.send(forward_dst, process.state[:val])
      end
    end
  end
end
