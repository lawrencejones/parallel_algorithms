require 'networks/ring'
require 'broadcasts/ring/one_to_all'

RSpec.describe(Broadcasts::Ring) do
  describe '.one_to_all_handler' do
    subject(:handler) { Broadcasts::Ring.method(:one_to_all_handler) }

    let(:network) { Networks::Ring.new(no_of_processes, &handler) }
    let(:no_of_processes) { 8 }
    let(:initial_src) { 0 }
    let(:log2p) { Math.log2(no_of_processes).ceil }

    let(:finished?) do
      lambda do |network|
        network.ps.select { |p| p.state[:val].nil? }.empty?
      end
    end

    # Seed initial sender
    before { network.ps[initial_src].state.merge!(step: log2p, val: 'VALUE') }

    it 'terminates in log_2(p) steps' do
      expect(network.run_until(&finished?)).to equal(log2p)
    end

    it 'costs (t_s + t_w * m) * log_2(p) + t_h * (p - 1)' do
      network.run_until(&finished?)
      expect(network.cost).to eql(ts: log2p, tw: log2p, th: no_of_processes - 1)
    end
  end
end
