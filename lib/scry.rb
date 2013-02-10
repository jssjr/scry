require "scry/version"

require 'yaml'

if defined?(Rake)
  Dir.glob("#{File.dirname(__FILE__)}/scry/tasks/*.rake").each { |t| import t }
end

module Scry
  require "scry/hash_helper"
  require "scry/validations"
  require "scry/printer"
  require "scry/data_node"
  require "scry/param"
  require "scry/dsl"

  class ScryError < StandardError
  end

  class ScryfileNotFound < ScryError ; end
  class ConfigKeyNotFound < ScryError ; end
  class MissingRequiredParameter < ScryError ; end
  class ParameterTypeMismatch < ScryError ; end

  class << self
    attr_reader :scryfile, :data, :sources, :types, :descriptions

    def init(options = {})
      init_scry(options)
      self
    end

    def [](k)
      @data[k]
    end

    def fetch(*keys)
      value = @data
      keys.each do |k|
        value = value[k]
      end
      value
    end

    def add_source(sourcefile, options = {})
      @sources.push sourcefile
      sourcefile
    end

    def add_namespace(name, options = {})
      # convert the namespace array to a nested hash
      # ['a','b','c'].reverse.unshift({}).inject {|a,n| {n => a}}
      # => {"a"=>{"b"=>{"c"=>{}}}}
      incoming = hashify(options[:current_namespace].push(name))
      @data = DataNode.from_hash(@data.rmerge(incoming))
      name
    end

    def add_param(name, options = {})
      if options[:default]
        value = options[:default]
      else
        value = nil
      end

      if options[:type]
        @types = @types.rmerge(hashify([options[:current_namespace], name].flatten, options[:type]))
      end

      if options[:description]
        @descriptions = @descriptions.rmerge(hashify([options[:current_namespace], name].flatten, options[:description]))
      end

      incoming = hashify([options[:current_namespace], name].flatten, value)
      @data = DataNode.from_hash(@data.rmerge(incoming))
      @data
    end

    private

    def init_scry(options)
      if options[:data]
        @data = DataNode.from_hash(options[:data])
      else
        @data = DataNode.new #{|h,k| h[k]=DataNode.new(&h.default_proc)}
      end

      @sources = []
      @types = {}
      @descriptions = {}

      @scryfile = find_and_load_scryfile(options)

      merge_sources

      Scry::Validations.run_all
    end

    def find_and_load_scryfile(options)
      if options[:scryfile_contents]
        Scry::Dsl.evaluate_scryfile(options)
      else
        scryfile = find_scryfile
        raise ScryfileNotFound, "Could not locate Scryfile" unless scryfile

        Scry::Dsl.evaluate_scryfile(:scryfile_path => scryfile)

        scryfile
      end
    end

    def find_scryfile
      given = ENV['SCRYFILE']
      return given if given && !given.empty?

      previous = nil
      current = File.expand_path(Dir.pwd)

      until !File.directory?(current) || current == previous
        filename = File.join(current, 'Scryfile')
        return filename if File.file?(filename)
        current, previous = File.expand_path("..", current), current
      end
    end

    def hashify(array, value = DataNode.new)
      # convert the narray to a nested hash
      # ['a','b','c'].reverse.unshift({}).inject {|a,n| {n => a}}
      # => {"a"=>{"b"=>{"c"=>Scry::DataNode}}
      array.reverse.unshift(value).inject {|a,n| {n=>a}}
    end

    def merge_sources
      @sources.each do |source|
        begin
          File.open(source, 'r') do |f|
            @data = DataNode.from_hash(@data.rmerge(YAML.load(f.read)))
          end
        rescue Errno::ENOENT => e
        end
      end
    end

  end
end
