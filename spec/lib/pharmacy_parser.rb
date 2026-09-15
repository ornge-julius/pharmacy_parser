require "rails_helper"

RSpec.describe Parser do

subject { described_class.new }

    describe "#parse_and_return" do
        it "parses and returns expected output" do
            expect(subject.parse_and_return(File.expand_path("../fixtures/file.txt", __dir__))).to eq("expected output")
        end
    end
end