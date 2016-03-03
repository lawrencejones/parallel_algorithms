require_relative './network.rb'

class RingNetwork < Network
  def hops_between(src, dst)
    a, b = src > dst ? [dst, src] : [src, dst]
    [b - a, ps.size + a - b].min
  end
end
