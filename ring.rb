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
