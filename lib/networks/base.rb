# Simulates network with cut-through routing
module Networks
  class Base
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
        @cost[:tw] += [*val].flatten.count

        net.send(i, dst, val)
      end
    end

    def initialize(p, &handler)
      @ps = (0..p - 1).map { |i| Process.new(i, self) }
      @handler = handler
      @pending_messages = []
    end

    attr_reader :ps, :pending_messages

    def hops_between(_src, _dst)
      fail NotImplementedError, 'Must be defined in subclass'
    end

    def step
      ps.each { |p| p.in.clear } # clear old messages

      until (src, dst, val = @pending_messages.pop).nil?
        ps[dst].in << [src, val]
      end

      ps.each { |p| @handler.call(self, p) }
    end

    # Runs the network until the condition is satisfied/we have stepped p times.
    # If the condition is never satisfied then return -1.
    def run_until(&_condition)
      for i in 0..ps.size
        step
        return i if yield self
      end

      -1
    end

    def active?
      pending_messages.any?
    end

    def send(src, dst, val)
      pending_messages << [src, dst, val]
    end

    def cost
      ps.max_by { |p| p.cost.values.inject(:+) }.cost
    end
  end
end
