require "thor"

class CLI < Thor
  def self.exit_on_failure?
    true
  end

  desc "parse FILE_PATH", "Parse a pharmacy events file and print a summary"
  def parse(file_path = File.expand_path("../fixtures/file.txt", __dir__))
    parser = Parser.new
    parser.parse_and_return(file_path)
  end
end
