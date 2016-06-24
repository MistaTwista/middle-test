require 'prime'

class FileParser
  def initialize(*args)
    @file_to_parse = args.shift
    @options = {}
    populate_options(args)
  end

  def parse
    raise ArgumentError unless File.exist?(@file_to_parse)
    @options["-o"] ? parse_file_to_file : parse_file_to_stdout
  end

  private

  def parse_file_to_stdout
    input_file = File.open(@file_to_parse, 'r')
    read_limited(input_file, Kernel)
  end

  def parse_file_to_file
    input_file = File.open(@file_to_parse, 'r')
    output_file = File.open(@options["-o"], 'w')
    read_limited(input_file, output_file)
  end

  def read_limited(input_file, object)
    0.tap do |counter|
      while !input_file.eof?
        break if counter == @options["-l"]
        line = input_file.readline.to_i
        if Prime.prime?(line)
          object.puts line
          counter += 1
        end
      end
    end
    return true
  end

  def populate_options(params)
    @options["-l"] = 10
    if available_options(params[0])
      @options[params[0]] = params[1]
    end
  end

  def available_options(symbol)
    %w(-o).include? symbol
  end
end

parser = FileParser.new(*ARGV).parse if ARGV.any?
