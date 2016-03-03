require_relative './network.rb'

class HypercubeNetwork < Network
  def hops_between(src, dst)
    (src ^ dst).to_s(2).count('1')
  end
end
