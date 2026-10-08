# frozen_string_literal: true

RSpec.describe "custom dispatchers" do
  subject { Test::Foo.new "123" }

  before do
    dispatcher = ->(op) { op[:integer] ? op.merge(type: proc(&:to_i)) : op }
    Dry::Initializer::Dispatchers << dispatcher
  end

  # The Dispatcher's pipeline is process-global, so reset it after each
  # example. Re-trigger the eager initialization so subsequent tests (notably
  # ractor_spec) get a shareable default pipeline back — clearing to
  # nil alone would leave the lazy `||=` to fire from whichever Ractor
  # touches it next, and class-ivar writes from non-main Ractors are
  # forbidden.
  after do
    Dry::Initializer::Dispatchers.instance_variable_set(:@pipeline, nil)
    Dry::Initializer::Dispatchers.send(:pipeline)
  end

  context "with extend syntax" do
    before do
      class Test::Foo
        extend Dry::Initializer
        param :id, integer: true
      end
    end

    it "adds syntax sugar" do
      expect(subject.id).to eq 123
    end
  end

  context "with include syntax" do
    before do
      class Test::Foo
        include Dry::Initializer.define -> do
          param :id, integer: true
        end
      end
    end

    it "adds syntax sugar" do
      expect(subject.id).to eq 123
    end
  end
end
