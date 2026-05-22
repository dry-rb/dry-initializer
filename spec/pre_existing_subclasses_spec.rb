# frozen_string_literal: true

# Regression: when `extend Dry::Initializer` is applied to a class that
# already has subclasses, those subclasses must not share the parent's
# Config via inherited singleton methods.

RSpec.describe "extending a class that already has subclasses" do
  before do
    class Test::Parent; end
    class Test::Child < Test::Parent; end
    class Test::Grandchild < Test::Child; end
  end

  context "after extending the parent" do
    before { Test::Parent.extend(Dry::Initializer) }

    it "gives each existing subclass its own Config" do
      expect(Test::Child.dry_initializer)
        .not_to be(Test::Parent.dry_initializer)
      expect(Test::Grandchild.dry_initializer)
        .not_to be(Test::Parent.dry_initializer)
      expect(Test::Grandchild.dry_initializer)
        .not_to be(Test::Child.dry_initializer)
    end

    it "does not include the parent itself in its own children" do
      children = Test::Parent.dry_initializer.children
      expect(children).not_to include(Test::Parent.dry_initializer)
    end

    it "exposes existing subclasses as children" do
      expect(Test::Parent.dry_initializer.children)
        .to include(Test::Child.dry_initializer)
    end

    it "lets adding a param to the parent flow into the existing subclass" do
      Test::Parent.param :foo
      expect(Test::Child.new("hi").foo).to eq("hi")
    end

    it "does not pollute the parent when adding a param to the existing subclass" do
      Test::Child.param :bar
      expect(Test::Parent.dry_initializer.definitions).not_to have_key(:bar)
      expect(Test::Child.dry_initializer.definitions).to have_key(:bar)
    end
  end
end
