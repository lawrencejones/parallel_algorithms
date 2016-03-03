require 'networks/ring'
require 'broadcasts/ring/all_to_all'

RSpec.describe(Broadcasts::Ring) do
  describe '.all_to_all_handler' do
    subject(:handler) { Broadcasts::Ring.method(:all_to_all_handler) }

    let(:network) { Networks::Ring.new(no_of_processes, &handler) }
    let(:no_of_processes) { 8 }

    let(:finished?) do
      lambda do |network|
        network.ps.select do |p|
          p.state.fetch(:stack, []).compact.uniq.size < no_of_processes
        end.empty?
      end
    end

    it 'terminates in (p - 1) steps' do
      expect(network.run_until(&finished?)).to equal(no_of_processes - 1)
    end

    it 'costs (p - 1)(t_s + t_h + m*t_w)' do
      network.run_until(&finished?)
      expect(network.cost).to eql(ts: no_of_processes - 1,
                                  th: no_of_processes - 1,
                                  tw: no_of_processes - 1)
    end
  end
end
