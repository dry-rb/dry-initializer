# frozen_string_literal: true

describe "unknow param" do
  before do
    class Test::Foo
      extend Dry::Initializer

      param :foo
      param :bar, optional: true
    end
  end

  it "suports unknown params" do
    subject = Test::Foo.new(1, 2, 3, 4)

    expect(subject.__dry_initializer_unknown_params__).to eq([3, 4])
  end

  it "suports unknown params with last as hash" do
    subject = Test::Foo.new(1, 2, 3, {fizz: 4})

    expect(subject.__dry_initializer_unknown_params__).to eq([3, {fizz: 4}])
  end

  context "with custom rest params" do
    before do
      class Test::Bar
        extend Dry::Initializer

        param :foo
        param :bar, optional: true
        rest_params :qux
      end
    end

    it "supports unknown options" do
      subject = Test::Bar.new(1, 2, 3, 4)

      expect(subject.qux).to eq([3, 4])
    end
  end

  context "without rest params" do
    before do
      class Test::Bar
        extend Dry::Initializer

        param :foo
        param :bar, optional: true
        rest_params false
      end
    end

    it "raise an ArgumentError" do
      expect { Test::Bar.new(1, 2, 3, 4) }.to raise_exception ArgumentError
    end
  end
end

describe "unknown option" do
  before do
    class Test::Foo
      extend Dry::Initializer

      option :foo
      option :bar, optional: true
    end
  end

  it "supports unknown options" do
    subject = Test::Foo.new(foo: 1, bar: 2, fizz: 3, buzz: 4)

    expect(subject.__dry_initializer_unknown_options__).to eq(fizz: 3, buzz: 4)
  end

  context "with custom rest options" do
    before do
      class Test::Bar
        extend Dry::Initializer

        option :foo
        option :bar, optional: true
        rest_options :kwargs
      end
    end

    it "supports unknown options" do
      subject = Test::Bar.new(foo: 1, bar: 2, fizz: 3, buzz: 4)

      expect(subject.kwargs).to eq(fizz: 3, buzz: 4)
    end
  end

  context "with out rest options" do
    before do
      class Test::Bar
        extend Dry::Initializer

        option :foo
        option :bar, optional: true
        rest_options false
      end
    end

    it "raise an ArgumentError" do
      expect { Test::Bar.new(foo: 1, bar: 2, fizz: 3, buzz: 4) }.to raise_exception ArgumentError
    end
  end
end
