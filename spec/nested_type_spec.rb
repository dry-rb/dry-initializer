describe "nested type argument" do
  subject { Test::Xyz.new("bar" => { "baz" => 42 }) }

  context "with nested definition only" do
    before do
      class Test::Xyz
        extend Dry::Initializer

        param :foo, as: :x do
          option :bar, as: :y do
            option :baz, proc(&:to_s), as: :z
            option :qux, as: :w, optional: true
          end
        end
      end
    end

    it "builds the type" do
      expect(subject.x.y.z).to eq "42"
    end
  end

  context "with nested and wrapped definitions" do
    before do
      class Test::Xyz
        extend Dry::Initializer

        param :foo, [], as: :x do
          option :bar, as: :y do
            option :baz, proc(&:to_s), as: :z
            option :qux, as: :w, optional: true
          end
        end
      end
    end

    it "builds the type" do
      x = subject.x
      expect(x).to be_instance_of Array

      expect(x.first.y.z).to eq "42"
    end
  end
end
