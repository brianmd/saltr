#!/usr/bin/ruby
require 'json'
require 'yaml'
require 'pp'
require 'readline'
require 'pathname'

require_relative 'saltr/version'
require_relative 'help'

module Saltr
  class Repl
    attr_accessor :minions, :last_result, :out, :static

    def initialize
      @minions = '*'
      @last_result = nil
      @out = :json
      @static = true
      initialize_readline
    end
    
    def repl
      stty_save = `stty -g`.chomp

      while (1) do
        print "\n#{'-'*50}\n"
        prompt = "salt '#{@minions}' --out=#{out}: "
        # cmd = Readline.readline(prompt, true)
        cmd = readline_with_hist_management(prompt)
        break if cmd.nil?
        result = run(cmd)
        print_result(result)
      end
    rescue Interrupt
      $stderr.puts "\n\nCtrl-c pressed."
    ensure
      store_history
      system('stty', stty_save)
    end

    def run_yaml(cmd, debug=false)
      YAML.load(run(cmd, debug))
    end

    def run(cmd, debug=false)
      parsed_cmd = parse(cmd)
      puts parsed_cmd
      result = if parsed_cmd.class==Array and parsed_cmd.first==:result
                 parsed_cmd[1]
               else
                 parsed_cmd = "#{parsed_cmd} --out=#{@out}"
                 # parsed_cmd += " --static" if static
                 `#{parsed_cmd}`
               end
      puts "result:#{result}:" if debug
      result
    end

    def parse(cmd)
      tokens = cmd.split(/[= ]/, 2)
      case tokens[0]
      when 'help'
        [:result, help(tokens[1])]
      when 'r'
        parse_cmd_run(tokens[1])
      when 'm'
        [:result, set_minion(tokens[1])]
      when 'o'
        [:result, set_out(tokens[1])]
      when /^salt-key/,/^salt-cloud/
      	cmd
      when 'quit'
        exit(0)
      else
        parse_salt(cmd)
      end
    end

    def print_result(result)
      puts result unless result.nil?
      #YAML.load(result)
    end
    
    def parse_salt(cmd)
      # "salt '#{minions}' cmd.run_all --out=json --static --no-color '#{cmd}'"
      "salt '#{minions}' #{cmd}"
    end
    
    def parse_cmd_run(cmd)
      "salt '#{minions}' cmd.run_all --static '#{cmd}'"
    end
    
    def set_minion(cmd)
      @minions = cmd
      cmd
    end
    
    def set_out(cmd)
      @out = cmd
      cmd
    end
    
    def help(cmd)
      cmd = 'top' if cmd=='' or cmd.nil?
      msg = "Help topic '#{cmd}' doesn't exist."
      begin
        msg = Help.new.send(cmd.to_sym)
      rescue
      end
      "HELP #{cmd}\n\n#{msg}"
    end

    def readline_with_hist_management(prompt='> ')
      line = Readline.readline(prompt, true)
      return nil if line.nil?
      if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
        Readline::HISTORY.pop
      end
      line
    end

    def initialize_readline
      load_history
      Readline.completion_append_character = ' '
      Readline.completion_proc = readline_proc
    end

    def readline_proc
      cmd_list = [
        'cmd.run', 'cmd.run_all',
        'sys.list_modules', 'sys.list_functions', 'sys.doc',
      ]
      proc { |s| cmd_list.grep(/^#{Regexp.escape(s)}/) }
    end

    def load_history
      history_file.open('r').readlines.each do |line|
        puts line
        Readline::HISTORY.push line.chomp
      end
    rescue
    end

    def store_history
      history_file.open('w') do |out|
        Readline::HISTORY.each do |line|
        puts line
          out.puts line
        end
      end
    rescue
    end

    def history_file
      Pathname(__FILE__).dirname + '.history'
    end
  end
end


if __FILE__ == $0
  Saltr::Repl.new.repl
end
