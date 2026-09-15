require "rails_helper"

RSpec.describe Parser do

    describe "#parse_and_return" do
        # happy path test
        context "events in order" do
            let(:parser) { described_class.new() }
            let(:expected_output) { File.read('spec/fixtures/expected_output.txt') + "\n" }
            it "parses and returns expected output" do
                expect { parser.parse_and_return(File.expand_path("../fixtures/happy_file.txt", __dir__)) }.to output(expected_output).to_stdout
            end
        end
        
        context "return before filled" do
            let(:parser) { described_class.new() }
            let(:expected_output) { File.read('spec/fixtures/return_before_filled_output.txt') + "\n" }
            it "parses and returns expected output" do
                expect { parser.parse_and_return(File.expand_path("../fixtures/return_before_filled_input.txt", __dir__)) }.to output(expected_output).to_stdout
            end
        end

        context "filled before created" do
            let(:parser) { described_class.new() }
            let(:expected_output) { File.read('spec/fixtures/filled_before_created_output.txt') + "\n" }
            it "parses and returns expected output" do
                expect { parser.parse_and_return(File.expand_path("../fixtures/filled_before_created_input.txt", __dir__)) }.to output(expected_output).to_stdout
            end
        end

        context "returned with no filled" do
            let(:parser) { described_class.new() }
            let(:expected_output) { File.read('spec/fixtures/return_with_no_fills_output.txt') + "\n" }
            it "parses and returns expected output" do
                expect { parser.parse_and_return(File.expand_path("../fixtures/return_with_no_fills_input.txt", __dir__)) }.to output(expected_output).to_stdout
            end
        end

        #handle missing patient

        #handle missing prescription

        #handle
    end
end