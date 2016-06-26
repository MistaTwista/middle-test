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
        break if counter == @options["-l"].to_i
        line = input_file.readline.to_i
        if Prime.prime?(line)
          object.puts line
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
    @options["-n"] = get_proc_num
  end

  def available_options(symbol)
    %w(-o -l -n).include? symbol
  end

  def get_proc_num
    if RUBY_PLATFORM =~ /linux/
      return `cat /proc/cpuinfo | grep processor | wc -l`.to_i
    elsif RUBY_PLATFORM =~ /darwin/
      return `sysctl -n hw.logicalcpu`.to_i
    end
    return 1
  end
end

parser = FileParser.new(*ARGV).parse if ARGV.any?
