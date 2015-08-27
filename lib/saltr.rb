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
    attr_accessor :minions, :last_result, :out, :static, :main_minion

    def initialize
      @minions = '*'
      @last_result = nil
      @out = :json
      @static = true
      @main_minion = 'gru'
      initialize_readline
    end
    
    def repl
      stty_save = `stty -g`.chomp

      while (true) do
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
                 parsed_cmd = "#{parsed_cmd} --out=#{@out}" unless parsed_cmd.match(/--out/)
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
      when 'l'
        parse_list(tokens[1])
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
    
    def parse_salt(cmd, minions=minion_str, out_type=out)
      "salt #{minions} --out=#{out_type} #{cmd}"
    end
    
    def parse_cmd_run(cmd)
      "salt #{minion_str} cmd.run_all --static '#{cmd}'"
    end

    def parse_list(cmd)
      puts cmd.inspect
      type = 'sys.list_modules'
      rest = ''
      out_type = 'raw'
      unless cmd.nil?
        args = cmd.split(/\s+/, 2)
        case args.first
        when 'functions'
          type = 'sys.list_functions'
          rest = args[1]
        when 'doc'
          type = 'sys.list_functions'
          rest = args[1]
          out_type = 'txt'
        else
          if args[0].match(/\./)
            type = 'sys.doc'
            out_type = 'txt'
          else
            type = 'sys.list_functions'
          end
          rest = args[0]
        end
      end
      cmd = type
      cmd = "#{cmd} #{rest}"
      parse_salt(cmd, main_minion, out_type)
    end
    
    def set_minion(cmd)
      @minions = cmd
      cmd
    end

    def minion_str
      if minions.match(/ and /)
        "-C '#{minions}'"
      else
        "'#{minions}'"
      end
    end
    
    def set_out(cmd)
      @out = cmd
      cmd
    end

    def help(cmd)
      puts cmd.inspect
      cmd = 'top' if cmd=='' or cmd.nil?
      puts helpr.inspect
      msg = "Help topic '#{cmd}' doesn't exist."
      begin
        msg = helpr[cmd]
        #msg = Help.new.send(cmd.to_sym)
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
      # TODO: limit the history size
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
        #'sys.list_modules', 'sys.list_functions', 'sys.doc',
        'l', 'l modules', 'l functions', 'l doc',
        'rbenv', 'rbenv.install'
      ]
      proc { |s| cmd_list.grep(/^#{Regexp.escape(s)}/) }
    end

    def load_history
      history_file.open('r').readlines.each do |line|
        Readline::HISTORY.push line.chomp
      end
    rescue
    end

    def store_history
      history_file.open('w') do |out|
        Readline::HISTORY.each do |line|
          out.puts line
        end
      end
#    rescue
    end

    def history_file
      Pathname.new("#{ENV['HOME']}/.saltr_history")
    end
  end
end


if __FILE__ == $0
  Saltr::Repl.new.repl
end
