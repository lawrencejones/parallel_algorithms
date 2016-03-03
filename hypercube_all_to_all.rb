require_relative './hypercube.rb'

# Runs a hypercube simulation to compute communication cost of all-to-all transmission
# algorithm.
#
# Usage...
#
#     ./hypercube_all_to_all.rb <no-of-processes>
#

no_of_processes = ARGV.first.to_i

network = HypercubeNetwork.new(no_of_processes) do |process|
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

while network.ps.select { |p| [*p.state[:stack]].compact.uniq.size < network.ps.size }.any?
  puts('[STEP!]')
  network.step
end

puts(%(
Total latency expected to be:
sum_{i=1}^{log_2(p)} (t_s + t_h + 2^{i-1}*t_w*m), p=#{network.ps.size}, m=1

Computed latency to be: ), network.ps.max_by { |p| p.cost.values.inject(:+) }.cost)
