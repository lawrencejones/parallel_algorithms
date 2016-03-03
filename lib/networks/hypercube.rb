require_relative './base'

module Networks
  class Hypercube < Base
    def hops_between(src, dst)
      (src ^ dst).to_s(2).count('1')
    end
  end
end
