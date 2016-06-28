# TODO: Multi threaded parser
# Нужно разобрать уже весь файл по тем же самым условиям, только в несколько
# потоков. Кол-во потоков указывается параметром -n и должно быть от 1 до 32,
# в случае если не указано, должно быть равно кол-ву процессоров в системе.
# При возможности придумать как организовать хронологическую запись в файл.

require 'prime'

class FileParser
  def initialize(*args)
    @file_to_parse = args.shift
    file_exist_validation(@file_to_parse)
    @options = {}
    populate_options(args)
  end

  def parse
    total_lines = get_lines_count(@file_to_parse)
    cpu_num = @options["-n"].to_i
    thread_step, remainder =  total_lines.divmod(cpu_num)
    next_thread_range = 1
    threads = []
    cpu_num.times do |i|
      current_step = next_thread_range
      step_length = thread_step + remainder
      threads[i] = Thread.new do
        Thread.current.thread_variable_set(:id, i)
        start_parser(current_step, step_length);
      end
      next_thread_range += step_length
      remainder = 0 if i == 0 # first thread do more work if needed
    end
    threads.each { |t| t.join }
    sort_output if output_to_file?
  end

  private

  def start_parser(from, length)
    output_to_file? ? to_file(from, length) : to_stdout(from, length)
  end

  def to_stdout(from_line = 1, length = @options["-l"].to_i)
    File.open(@file_to_parse, 'r') do |input_file|
      read_limited(input_file, Kernel, from_line, length)
    end
  end

  def to_file(from_line = 1, length = @options["-l"].to_i)
    File.open(@file_to_parse, 'r') do |input_file|
      File.open(@options["-o"], 'a') do |output_file|
        read_limited(input_file, output_file, from_line, length)
      end
    end
  end

  def read_limited(input_file, object, from_line, length)
    # (from_line - 1).times { input_file.gets } # fast forward
    id = Thread.current.thread_variable_get(:id)
    print "THREAD #{id} started real work\n"
    counter = 1
    input_file.each_line do |line|
      line_no = input_file.lineno
      next if line_no < from_line
      break if counter > length
      if Prime.prime?(line.to_i)
        # print "ID(#{id}) Line##{input_file.lineno}\n"
        object.print "#{line_no};#{line}"
      end
      counter += 1
    end
    return true
    # 1.tap do |counter|
    #   while !input_file.eof?
    #     line_no = input_file.lineno
    #     line = input_file.readline.to_i
    #   end
    # end
    # return true
  end

  def sort_output(file = @options["-o"])
    `sort -n #{file} > #{file}.bak`
    `mv #{file}.bak #{file}`
  end

  def get_lines_count(file)
    `wc -l < "#{file}"`.to_i
  end

  def populate_options(options)
    setup_default_options
    options.each_with_index do |opt, index|
      @options[opt] = options[index + 1] if available_options(opt)
    end
    validate_options
  end

  def output_to_file?
    @options["-o"]
  end

  def setup_default_options
    @options["-l"] = 10
    @options["-n"] = get_proc_num
  end

  def validate_options
    range_validation("-n", 1..32)
  end

  def range_validation(name, range)
    unless (range).include? @options[name].to_i
      raise ArgumentError.new("Option '#{name}' must be in range #{range}")
    end
  end

  def file_exist_validation(file)
    raise ArgumentError.new("#{file} not found") unless File.exist?(file)
  end

  def available_options(symbol)
    %w(-o -l -n).include? symbol
  end

  def get_proc_num
    case RbConfig::CONFIG['host_os']
    when /linux/
      return `cat /proc/cpuinfo | grep processor | wc -l`.to_i
    when /darwin/
      return `sysctl -n hw.logicalcpu`.to_i
    end
    return 1
  end
end

started_at = Time.now

parser = FileParser.new(*ARGV).parse if ARGV.any?

long = (Time.now - started_at).round(2)
p "Created in #{long} seconds"
# "Created in 79.43 seconds"
