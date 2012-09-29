require 'ansi/code'

module Foundry
  class REPL
    COMMANDS = {}

    attr_accessor :interleave_backtraces

    def initialize(runtime, interp)
      self.class.initialize_readline!

      @runtime   = runtime
      @interp    = interp
      @scope     = interp.innermost_scope

      @terminate = false

      @interleave_backtraces = false
    end

    def self.initialize_readline!
      unless @readline_initialized
        require 'readline'

        Readline.basic_word_break_characters = ' '
        Readline.completion_append_character = ' '
        Readline.completion_proc = proc { |s| COMMANDS.keys.grep(/#{Regexp.escape(s)}/) }

        @readline_initialized = true
      end
    end

    def self.command(name, params, info, callback=:"#{name.gsub '-', '_'}")
      COMMANDS["\\#{name}"] = {
        params:    params,
        info:      info,
        callback:  callback,
      }
    end

    command '?', nil, "Display this screen", :help
    def help(cmdline)
      puts "Command list:"
      COMMANDS.each do |command, options|
        puts "%20s %-8s %s" % [command, options[:params], options[:info]]
      end
    end

    command 'return', nil, "(or ^D) Return from innermost REPL"
    def return(cmdline)
      @terminate = true
    end

    command 'quit', nil, "Terminate interpreter"
    def quit(cmdline)
      exit!
    end

    command 'graph_ast', ":bool", "Draw AST graphs after parsing code"
    def graph_ast(cmdline)
      boolean_command 'graph_ast', cmdline, @runtime, :graph_ast
    end

    command 'include_host', ":bool", "Include host information in backtraces"
    def include_host(cmdline)
      boolean_command 'include_host', cmdline, self, :interleave_backtraces
    end

    command 'bt', nil, "Print backtrace leading to this REPL", :backtrace
    def backtrace(cmdline)
      @interp.collect_backtrace.flatten.each do |line|
        show_backtrace_line line, false
      end
    end

    command 'ls', ":expr", "Evaluate expression and describe result"
    def ls(cmdline)
      cmdline = (cmdline || "").strip
      if cmdline.empty?
        describe @scope.self
      else
        object = safe_eval(cmdline, '(ls-eval)')
        describe object unless object.equal? nil
      end
    end

    command 'ls-id', ":id", "Describe object by id"
    def ls_id(cmdline)
      describe ObjectSpace._id2ref(cmdline.to_i)
    end

    def describe(object)
      unless object.__vm_object?
        puts "Not a VM object."
        return
      end

      properties = {
        "instance of" => object.class.name,
      }

      if object.instance_variables.any?
        properties["instance variables"] = \
          object.instance_variables.map do |ivar|
            "@#{ivar}=#{object.instance_variable_get(ivar).inspect}"
          end
      end

      klass = object.class
      while klass
        if klass.instance_methods(false).any?
          properties["#{klass.name}#methods:"] = \
            klass.instance_methods(false).sort.join("  ")
        end
        klass = klass.upperclass
      end

      puts "Object #{object.__id__}:"
      properties.each do |property, value|
        print "  ", ANSI.bright, ANSI.white, property,
                    ANSI.reset, " ", value, "\n"
      end
    end

    def safe_eval(string, name='(repl)')
      @runtime.eval(string, name, @scope)

    rescue Melbourne::SyntaxError => e
      puts e.message
      puts e.code
      puts "#{"~" * (e.column - 1)}^"

    rescue Foundry::InterpreterError => e
      puts e.inner_exception.inspect
      e.interleave_backtraces(caller.length) do |line, is_host|
        next if is_host && !@interleave_backtraces
        show_backtrace_line line, is_host
      end

    rescue Exception => e
      puts "#{e.class}: #{e.message}"
      e.backtrace[0..-caller.length].each do |line|
        show_backtrace_line line
      end
    end

    PROMPT = "\001#{ANSI.green}\002f! \001#{ANSI.reset}\002"

    def invoke!
      puts "Foundry REPL. Type \\? to view command reference."
      puts "Self: #{@scope.self.inspect}"

      until @terminate
        begin
          string = Readline.readline(PROMPT, true)
        rescue Interrupt
          puts "^C"
          next
        end

        if string.nil?
          puts "^D"
          break
        end

        execute(string)
      end
    end

    def execute(string)
      if string.start_with? '\\'
        command, arg_line = string.split(/\s/, 2)

        unless COMMANDS.key? command
          puts "Unknown internal command #{command}."
          return
        end

        send COMMANDS[command][:callback], arg_line
      else
        result = safe_eval(string)
        p result if result.__vm_object?
      end
    end

    protected

    BOOLEAN_MAP = {
      'true' => true, 'false' => false,
      't'    => true, 'f'     => false,
      '1'    => true, '0'     => false,
      '+'    => true, '-'     => false
    }

    def boolean_command(command, arg, object, property)
      state     = object.send property

      new_state = BOOLEAN_MAP[arg]
      unless new_state.nil?
        object.send :"#{property}=", new_state
        state = new_state
      end

      puts "\\#{command}: #{state}"
    end

    FOUNDRY_ROOT = File.expand_path('../../..', __FILE__)

    def show_backtrace_line(line, is_host=true)
      line = line.to_s
      line = line.sub FOUNDRY_ROOT, 'FOUNDRY_ROOT'

      if is_host
        puts "  . #{line}"
      else
        puts "  ! #{line}"
      end
    end
  end
end