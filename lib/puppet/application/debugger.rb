# frozen_string_literal: true

require "puppet/application"
require "optparse"
require "puppet/util/command_line"

class Puppet::Application::Debugger < Puppet::Application
  attr_reader :use_stdin

  option("--execute EXECUTE", "-e") do |arg|
    options[:code] = arg
  end

  option("--facterdb-filter FILTER") do |arg|
    options[:use_facterdb] = true unless options[:node_name]
    ENV["DEBUGGER_FACTERDB_FILTER"] = arg if arg
  end

  option("--test") do |_arg|
    options[:quiet] = true
    options[:run_once] = true
    @use_stdin = true
  end

  option("--no-facterdb") { |_arg| options[:use_facterdb] = false }

  option("--log-level LEVEL", "-l") do |arg|
    Puppet::Util::Log.level = arg.to_sym
  end

  option("--catalog catalog",  "-c catalog") do |arg|
    options[:catalog] = arg
  end

  option("--quiet", "-q") { |_arg| options[:quiet] = true }

  option("--play URL", "-p") do |arg|
    options[:play] = arg
  end

  option("--stdin", "-s") { |_arg| @use_stdin = true }

  option("--run-once", "-r") { |_arg| options[:run_once] = true }

  option("--node-name CERTNAME", "-n") do |arg|
    options[:use_facterdb] = false
    options[:node_name] = arg
  end

  def help
    <<-HELP

puppet-debugger(8) -- Starts a debugger session using the puppet-debugger tool
========

SYNOPSIS
--------
A interactive command line tool for evaluating the puppet language and debugging
puppet code.

USAGE
-----
puppet debugger [--help] [--version] [-e|--execute CODE] [--facterdb-filter FILTER]
                [--test] [--no-facterdb] [-q|--quiet] [-p|--play URL] [-s|--stdin]
                [-r|--run-once] [-n|--node-name CERTNAME]


DESCRIPTION
-----------
A interactive command line tool for evaluating the puppet language and debugging
puppet code.

USAGE WITH DEBUG MODULE
-----------------------
Use the puppet debugger in conjunction with the debug::break() puppet function
to pry into your code during compilation.  Get immediate insight in how the puppet4
languge works during the execution of your code.

To use the break function install the module via: puppet module install nwops/debug

Now place the debug::break() function anywhere in your code to

Example:
  puppet debugger -e '$abs_vars = [-11,-22,-33].map | Integer $num | { debug::break() ; notice($num) }'

See: https://github.com/nwops/puppet-debug
OPTIONS
-------
Note that any setting that's valid in the configuration
file is also a valid long argument. For example, 'server' is a valid
setting, so you can specify '--server <servername>' as
an argument.

See the configuration file documentation at
http://docs.puppetlabs.com/references/stable/configuration.html for the
full list of acceptable parameters. A commented list of all
configuration options can also be generated by running puppet debugger with
'--genconfig'.

* --help:
  Print this help message

* --version:
  Print the puppet version number and exit.

* --execute:
  Execute a specific piece of Puppet code

* --facterdb-filter
  Disables the usage of the current node level facts and uses cached facts
  from facterdb.  Specifying a filter will override the default facterdb filter.
  Not specifiying a filter will use the default CentOS based filter.
  This will greatly speed up the start time of the debugger since
  you are using cached facts.  Additionally, using facterdb also allows you
  to play with many other operating system facts that you might not have access
  to.  For example filters please see the facterdb docs.

  See https://github.com/camptocamp/facterdb for more info

* --no-facterdb
  Use the facts found on this node instead of cached facts from facterdb.

* --log-level
  Set the Puppet log level which can be very useful with using the debugger.

* --quiet
  Do not display the debugger help script upon startup.

* --play
  Plays back the code file supplied into the debugger.  Can also supply
  any http based url.

* --run-once
  Return the result from the debugger and exit

* --stdin
  Read from stdin instead of starting the debugger right away.  Useful when piping code into the debugger.

* --catalog:
  Import a JSON catalog (such as one generated with 'puppet master --compile'). You need to
  specify a valid JSON encoded catalog file.  Gives you the ability
  to inspect the catalog and all the parameter values that make up the resources. Can 
  specify a file or pipe to stdin with '-'.

* --node-name
  Retrieves the node information remotely via the puppet server given the node name.
  This is extremely useful when trying to debug classification issues, as this can show
  classes and parameters retrieved from the ENC.  You can also play around with the real facts
  of the remote node as well.

  Note: this requires special permission in your puppet server's auth.conf file to allow
  access to make remote calls from this node: #{Puppet[:certname]}.  If you are running
  the debugger from the puppet server as root you do not need any special setup.

  You must also have a signed cert and be able to connect to the server from this system.

  Mutually exclusive with --facterdb-filter

* --test
  Runs the code in the debugger and exit without showing the help screen ( --quiet --run-once, --stdin)

EXAMPLE
-------
    $ puppet debugger
    $ echo "notice('hello, can you hear me?')" | puppet debugger --test
    $ echo "notice('hello, can you hear me?')" | puppet debugger --stdin
    $ puppet debugger --execute "notice('hello')"
    $ puppet debugger --facterdb-filter 'facterversion=/^2.4\./ and operatingsystem=Debian'
    $ puppet debugger --play https://gist.github.com/logicminds/4f6bcfd723c92aad1f01f6a800319fa4
    $ puppet debugger --facterdb-filter 'facterversion=/^2.4\./ and operatingsystem=Debian' \\
                      --play https://gist.github.com/logicminds/4f6bcfd723c92aad1f01f6a800319fa4
    $ puppet debugger --node-name


AUTHOR
------
Corey Osman <corey@nwops.io>


COPYRIGHT
---------
Copyright (c) 2019 NWOps

    HELP
  end

  def initialize(command_line = Puppet::Util::CommandLine.new)
    @command_line = CommandLineArgs.new(command_line.subcommand_name, command_line.args.dup)
    @options = { use_facterdb: true, play: nil, run_once: false,
      node_name: nil, quiet: false, help: false, scope: nil,
      catalog: nil }
    @use_stdin = false
    begin
      require "puppet-debugger"
    rescue LoadError => e
      Puppet.err("You must install the puppet-debugger: gem install puppet-debugger")
    end
  end

  def main
    # if this is a file we don't play back since its part of the environment
    # if just the code we put in a file and use the play feature of the debugger
    # we could do the same thing with the passed in manifest file but that might be too much code to show

    if options[:code]
      code_input = options.delete(:code)
      file = Tempfile.new(["puppet_debugger_input", ".pp"])
      File.open(file, "w") do |f|
        f.write(code_input)
      end
      options[:play] = file
    elsif command_line.args.empty? && use_stdin
      code_input = STDIN.read
      file = Tempfile.new(["puppet_debugger_input", ".pp"])
      File.open(file, "w") do |f|
        f.write(code_input)
      end
      options[:play] = file
    elsif !command_line.args.empty?
      manifest = command_line.args.shift
      raise "Could not find file #{manifest}" unless Puppet::FileSystem.exist?(manifest)
      Puppet.warning("Only one file can be used per run.  Skipping #{command_line.args.join(", ")}") unless command_line.args.empty?
      options[:play] = file
    end
    begin
      if !options[:use_facterdb] && options[:node_name].nil?
        debug_environment = create_environment(nil)
        Puppet.notice('Gathering node facts...')
        node = create_node(debug_environment)
        scope = create_scope(node)
        # start_debugger(scope)
        options[:scope] = scope
      end
      ::PuppetDebugger::Cli.start_without_stdin(options)
    rescue Exception => e
      puts e.backtrace
      exit 1
    end
  end

  def create_environment(manifest)
    configured_environment = Puppet.lookup(:current_environment)
    manifest ?
      configured_environment.override_with(manifest: manifest) :
      configured_environment
  end

  def create_node(environment)
    node = nil
    unless Puppet[:node_name_fact].empty?
      # Collect our facts.
      unless facts = Puppet::Node::Facts.indirection.find(Puppet[:node_name_value])
        raise "Could not find facts for #{Puppet[:node_name_value]}"
      end
      Puppet[:node_name_value] = facts.values[Puppet[:node_name_fact]]
      facts.name = Puppet[:node_name_value]
    end
    Puppet.override({ current_environment: environment }, "For puppet debugger") do
      # Find our Node
      unless node = Puppet::Node.indirection.find(Puppet[:node_name_value])
        raise "Could not find node #{Puppet[:node_name_value]}"
      end
      # Merge in the facts.
      node.merge(facts.values) if facts
    end
    node
  end

  def create_scope(node)
    compiler = Puppet::Parser::Compiler.new(node) # creates a new compiler for each scope
    scope = Puppet::Parser::Scope.new(compiler)
    # creates a node class
    scope.source = Puppet::Resource::Type.new(:node, node.name)
    scope.parent = compiler.topscope
    # compiling will load all the facts into the scope
    # without this step facts will not get resolved
    scope.compiler.compile # this will load everything into the scope
    scope
  end

  def start_debugger(scope, options = {})
    if $stdout.isatty
      options = options.merge(scope: scope)
      # required in order to use convert puppet hash into ruby hash with symbols
      options = options.each_with_object({}) { |(k, v), data| data[k.to_sym] = v; data }
      # options[:source_file], options[:source_line] = stacktrace.last
      ::PuppetRepl::Cli.start(options)
    else
      Puppet.info "puppet debug: refusing to start the debugger without a tty"
    end
  end

  # returns a stacktrace of called puppet code
  # @return [String] - file path to source code
  # @return [Integer] - line number of called function
  # This method originally came from the puppet 4.6 codebase and was backported here
  # for compatibility with older puppet versions
  # The basics behind this are to find the `.pp` file in the list of loaded code
  def stacktrace
    result = caller.each_with_object([]) do |loc, memo|
      if loc =~ /\A(.*\.pp)?:([0-9]+):in\s(.*)/
        # if the file is not found we set to code
        # and read from Puppet[:code]
        # $3 is reserved for the stacktrace type
        memo << [Regexp.last_match(1).nil? ? :code : Regexp.last_match(1), Regexp.last_match(2).to_i]
      end
      memo
    end.reverse
  end
end
