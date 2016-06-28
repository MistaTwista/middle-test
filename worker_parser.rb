require 'monitor'
require 'prime'
Thread.abort_on_exception = true

class FileParser
  def initialize(*args)
    @file_to_parse = args.shift
    file_exist_validation(@file_to_parse)
    get_total_lines
    @options = {}
    @processed = {}
    @processed[:lines] = 0
    populate_options(args)
    @threads = Array.new(threads_num)
    @results = Array.new
    @results_mutex = Mutex.new
    @work_queue = SizedQueue.new(threads_num)
    @work_queue_mutex = Mutex.new
    @threads.extend(MonitorMixin)
    @threads_available = @threads.new_cond
    @reader_exit = false

    @nums_found = 0
    @total_nums_checked = 0
    @total_lines_readed = 0
  end

  def parse
    run_reader_thread(File.open(@file_to_parse, 'r'))
    run_worker_thread
    run_monitor_thread

    @reader_thread.join
    @worker_thread.join
    @monitor_thread.join

    @threads.each do |thread|
      thread.join unless thread.nil?
    end
    sort_output if output_to_file?
  end

  private

  def reading_complete
    @reader_exit
  end

  def run_worker_thread
    @worker_thread = Thread.new do
      loop do
        break if reading_complete && @work_queue.length == 0
        found_index = nil

        @threads.synchronize do
          @threads_available.wait_while do
            @threads.select { |thread| thread.nil? || thread.status == false  ||
                                       thread["finished"].nil? == false }.length == 0
          end

          found_index = @threads.rindex { |thread| thread.nil? || thread.status == false ||
                                                   thread["finished"].nil? == false }
        end

        data = @work_queue.pop

        @threads[found_index] = run_analyzer_thread(data)
      end
    end
  end

  def run_analyzer_thread(data)
    Thread.new(data) do
      @results_mutex.synchronize do
        data.each do |p|
          line_no, num = p
          if Prime.prime?(num)
            # print "#{line_no} #{num}\n"
            @nums_found += 1
          end
          @total_nums_checked += 1
        end
      end

      Thread.current["finished"] = true

      @threads.synchronize do
        @threads_available.signal
      end
    end
  end

  def run_reader_thread(file)
    @reader_thread = Thread.new do
      lines_processed = 0
      data_portion = []

      file.each_line.with_index do |line, index|
        line_no = index + 1
        line_data = line.to_i
        @total_lines_readed = line_no

        loop do
          break if @work_queue.length <= @work_queue.max
        end

        data_portion << [line_no, line_data]
        difference = (lines_processed - line_no).abs
        # print "DP: #{data_portion.length}. LT: #{get_total_lines}\n"
        next if difference < chunk_size && data_portion.length != get_total_lines

        lines_processed = line_no
        # print "Data portion ready at #{lines_processed}, current: #{[line_no, line_data]}\n"
        @work_queue_mutex.synchronize do
          @work_queue << data_portion
          data_portion = []
        end
        # print "Line ##{index + 1}(#{work_queue.length}/#{work_queue.max}): #{line_data}\n"

        @threads.synchronize do
          @threads_available.signal
        end
      end

      @reader_exit = true
    end
  end

  def threads_status
    @threads.select { |thread| thread.nil? || thread.status == false  ||
                                       thread["finished"].nil? == false }
  end

  def run_monitor_thread
    @monitor_thread = Thread.new do
      loop do
        break if reading_complete && threads_status.length == threads_num
        checked_perc = percent_from(@total_nums_checked, get_total_lines)
        workers = "Workers: #{threads_status.length}:(#{@nums_found}/#{checked_perc}%)"
        dataline = "#{workers}\r"
        print dataline
        $stdout.flush
        sleep 0.1
      end
    end
  end

  def threads_num
    @options["-n"].to_i
  end

  def chunk_size
    @options["-c"].to_i
  end

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
    (from_line - 1).times { input_file.gets } # fast forward
    id = Thread.current.thread_variable_get(:id)
    puts "#{id} starting real work"
    1.tap do |counter|
      while !input_file.eof?
        break if counter > length
        line_no = input_file.lineno
        line = input_file.readline.to_i
        if Prime.prime?(line)
          object.print "#{line_no + 1};#{line}\n"
        end
        counter += 1
      end
    end
    return true
  end

  def percent_from(num, from)
    (num.to_f / from * 100).round(0)
  end

  def sort_output(file = @options["-o"])
    %x{ sort -n #{file} > #{file}.bak }
    %x{ mv #{file}.bak #{file} }
  end

  def get_total_lines(file = @file_to_parse)
    @total_lines ||= %x{ wc -l < "#{file}" }.to_i
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
    @options["-c"] = 1024 # chunk/lines by default
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
    %w(-o -l -n -c).include? symbol
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

parser = FileParser.new(*ARGV).parse if ARGV.any?
