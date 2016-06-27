require 'prime'

class FileParser
  def initialize(*args)
    @file_to_parse = args.shift
    @options = {}
    populate_options(args)
  end

  def parse
    unless File.exist?(@file_to_parse)
      raise ArgumentError.new("#{@file_to_parse} not found")
    end
    @options["-o"] ? parse_file_to_file : parse_file_to_stdout
  end

  private

  def parse_file_to_stdout
    File.open(@file_to_parse, 'r') do |input_file|
      read_limited(input_file, Kernel)
    end
  end

  def parse_file_to_file
    File.open(@file_to_parse, 'r') do |input_file|
      File.open(@options["-o"], 'w') do |output_file|
        read_limited(input_file, output_file)
      end
    end
  end

  def read_limited(input_file, object, length = @options["-l"].to_i)
    0.tap do |counter|
      until input_file.eof?
        break if counter > length
        line_no = input_file.lineno + 1
        line = input_file.readline.to_i
        if Prime.prime?(line)
          object.puts "#{line_no};#{line}"
          counter += 1
        end
      end
    end
    return true
  end

  def populate_options(options)
    setup_default_options
    options.each_with_index do |opt, index|
      @options[opt] = options[index + 1] if available_options(opt)
    end
  end

  def setup_default_options
    @options["-l"] = 10
  end

  def available_options(symbol)
    %w(-o -l).include? symbol
  end
end

parser = FileParser.new(*ARGV).parse if ARGV.any?
