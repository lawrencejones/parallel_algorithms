# Runs a ring simulation to verify the communication cost of an algorithm for one-to-all
# broadcasting that should be logscale.

# Simulates a ring network with cut-through routing
class RingNetwork
  class Process
    def initialize(i, net)
      @i = i
      @net = net
      @in = []
      @cost = { ts: 0, th: 0, tw: 0 }
      @state = {}
    end

    attr_reader :i, :in, :out, :cost, :net, :state

    def send(dst, val)
      @cost[:ts] += 1
      @cost[:th] += net.hops_between(i, dst)
      @cost[:tw] += 1

      net.send(i, dst, val)
    end
  end

  def initialize(p, &handler)
    @ps = (0..p-1).map { |i| Process.new(i, self) }
    @handler = handler
    @pending_messages = []
  end

  attr_reader :ps, :pending_messages

  def hops_between(src, dst)
    a, b = src > dst ? [dst, src] : [src, dst]
    [b - a, ps.size + a - b].min
  end

  def step
    ps.each { |p| p.in.clear }  # clear old messages

    until (src,dst,val = @pending_messages.pop).nil?
      ps[dst].in << [src, val]
    end

    ps.each { |p| @handler.call(p) }
  end

  def send(src, dst, val)
    pending_messages << [src, dst, val]
  end
end

network = RingNetwork.new(8) do |process|
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
network.ps[ARGV[0].to_i].state.merge!(step: Math.log2(network.ps.size).ceil, val: 'VALUE')

while network.ps.select { |p| p.state[:val].nil? }.any?
  puts('[STEP!]')
  network.step
end

puts(%(
Total latency expected to be:
(t_s + t_w * m) * log_2(p) + t_h * (p - 1), p=#{network.ps.size}, m=1

Computed latency to be: ), network.ps.max_by { |p| p.cost.values.inject(:+) }.cost)
