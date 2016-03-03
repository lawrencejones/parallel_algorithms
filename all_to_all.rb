require_relative './ring.rb'

# Runs a ring simulation to verify the communication cost of an all-to-all transmission
# algorithm.
#
# Usage...
#
#     ./all_to_all <no-of-processes>
#

no_of_processes = ARGV.first.to_i

network = RingNetwork.new(no_of_processes) do |process|
  stack = process.state[:stack] ||= [process.i]

  unless (_, val = process.in.first).nil?
    stack << val
  end

  if stack.uniq.size < network.ps.size
    process.send((process.i + 1) % network.ps.size, stack.last)
  end
end

while network.ps.select { |p| [*p.state[:stack]].compact.uniq.size < network.ps.size }.any?
  puts('[STEP!]')
  network.step
end

puts(%(
Total latency expected to be:
(p - 1)(t_s + t_h + m*t_w), p=#{network.ps.size}, m=1

Computed latency to be: ), network.ps.max_by { |p| p.cost.values.inject(:+) }.cost)
