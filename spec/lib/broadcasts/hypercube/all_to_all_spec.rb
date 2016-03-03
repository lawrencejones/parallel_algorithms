require 'networks/hypercube'
require 'broadcasts/hypercube/all_to_all'

RSpec.describe(Broadcasts::Hypercube) do
  describe '.all_to_all_handler' do
    subject(:handler) { Broadcasts::Hypercube.method(:all_to_all_handler) }

    let(:network) { Networks::Hypercube.new(no_of_processes, &handler) }
    let(:no_of_processes) { 8 }
    let(:log2p) { Math.log2(no_of_processes).ceil }

    let(:finished?) do
      lambda do |network|
        network.ps.select do |p|
          p.state.fetch(:stack, []).compact.uniq.size < no_of_processes
        end.empty?
      end
    end

    it 'terminates in log_2(p) steps' do
      expect(network.run_until(&finished?)).to equal(log2p)
    end

    it 'costs sum_{i=1}^{log_2(p)} (t_s + t_h + 2^{i-1}*t_w*m)' do
      network.run_until(&finished?)
      expect(network.cost).to eql(ts: log2p, th: log2p, tw: no_of_processes - 1)
    end
  end
end
