require 'questions/collective_mesh'

RSpec.describe(Questions::CollectiveMesh) do
  subject(:mesh) { described_class.new(no_of_processes) }

  let(:no_of_processes) { 9 }
  let(:expected_result) { (0..no_of_processes - 1).to_a }

  it 'runs until all nodes have every i' do
    mesh.run_until { |n| !n.active? }
    mesh.ps.each do |p|
      expect(p.state[:vector].sort).to eql(expected_result)
    end
  end

  it 'costs 2ts*(p^0.5 -1) + (tw + th)(p - 1) ' do
    mesh.run_until { |n| !n.active? }
    expect(mesh.cost).to eql(ts: 2 * (Math.sqrt(no_of_processes).floor - 1),
                             th: no_of_processes - 1,
                             tw: no_of_processes - 1)
  end
end
