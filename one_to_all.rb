require_relative './ring.rb'

# Runs a ring simulation to verify the communication cost of an algorithm for one-to-all
# broadcasting that should be logscale.
#
# Usage...
#
#     ./one_to_all <no-of-processes> <initial-src-node>
#

no_of_processes, initial_src_node = ARGV.map(&:to_i)

network = RingNetwork.new(no_of_processes) do |process|
  # If we received a message then start our own counter
  for src,val in process.in
    puts "[#{process.i}] Received value #{val}!"
    prev_step_no = Math.log2(network.hops_between(src, process.i)).to_i

    process.state.merge!(step: prev_step_no, val: val)
  end

  # Now we have the value, forward it to the next node
  unless process.state[:val].nil? || process.state[:step] == 0
    process.state[:step] -= 1
    forward_dst = process.i + 2**(process.state[:step])
    forward_dst -= network.ps.size if forward_dst >= network.ps.size

    process.send(forward_dst, process.state[:val])
  end
end

# Init the start node
network.ps[initial_src_node].state.
  merge!(step: Math.log2(network.ps.size).ceil, val: 'VALUE')

while network.ps.select { |p| p.state[:val].nil? }.any?
  puts('[STEP!]')
  network.step
end

puts(%(
Total latency expected to be:
(t_s + t_w * m) * log_2(p) + t_h * (p - 1), p=#{network.ps.size}, m=1

Computed latency to be: ), network.ps.max_by { |p| p.cost.values.inject(:+) }.cost)
