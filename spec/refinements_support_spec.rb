describe "refinements" do
  before do
    module Test::BarRefinement
      refine Fixnum do
        def bar
          "#{self} bar"
        end
      end
    end

    class Test::Foo
      extend Dry::Initializer::Mixin

      using Test::BarRefinement

      param :foo

      def foo_bar
        foo.bar
      end
    end
  end

  it "works with dry-initializer" do
    subject = Test::Foo.new(1)

    expect(subject.foo).to eql 1
    expect(subject.foo_bar).to eql "1 bar"
  end
end
