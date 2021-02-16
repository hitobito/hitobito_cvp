module Guess

  def test
    require 'rspec/autorun'
    require 'rspec/collection_matchers'

    RSpec.configure do |config|
      config.filter_run_when_matching focus: true
    end

    describe 'row' do
      it 'indents to_s' do
        rows = [GroupRow.new(1, 'CVP Schweiz', nil),
                GroupRow.new(2, 'Kantonalparteien', 1),
                GroupRow.new(3, 'CVP SG', 2)]
        applied = Spike.new.apply_parents(rows)
        expect(applied.first.to_s).to start_with('<')
        expect(applied.second.to_s).to start_with(' <')
        expect(applied.third.to_s).to start_with('  <')
      end
    end

    describe Spike do
    end

  end

  def run
    Spike.new(tree_ids: [1, 167], depth: 5).run
  end

  module_function :run, :test
end

