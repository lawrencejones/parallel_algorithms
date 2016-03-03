require_relative '../../networks/ring'

module Broadcasts
  module Ring
    def self.all_to_all_handler(network, process)
      stack = process.state[:stack] ||= [process.i]

      unless (_, val = process.in.first).nil?
        stack << val
      end

      if stack.uniq.size < network.ps.size
        process.send((process.i + 1) % network.ps.size, stack.last)
      end
    end
  end
end
