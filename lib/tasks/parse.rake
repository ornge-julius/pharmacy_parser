task :parse, [:file_path] => :environment do |t, args|
    args.with_defaults(file_path: '../fixtures/file.txt')
    puts "Parsing file: #{args.file_path}"
    # parser = Parser.new
    # parser.parse_and_return(args.file_path)
end
