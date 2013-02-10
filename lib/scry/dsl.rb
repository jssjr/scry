module Scry
  class Dsl
    class << self
      attr :scryfile_path, :scryfile_contents

      def evaluate_scryfile(options)
        if options.has_key?(:scryfile_path)
          raise ScryfileNotFound unless File.exists?(options[:scryfile_path])
          @scryfile_path = options[:scryfile_path]
          @scryfile_contents = fetch_scryfile_contents(options[:scryfile_path])
        elsif options.has_key?(:scryfile_contents)
          @scryfile_contents = options[:scryfile_contents]
        end
        @scryfile_contents ||= ''

        instance_eval_scryfile
      end

      private

      def fetch_scryfile_contents(scryfile)
        begin
          File.read(scryfile)
        rescue
          puts "Error reading Scryfile"
          exit 1
        end
      end

      def instance_eval_scryfile
        @scryfile_contents ||= ''

        new.instance_eval(@scryfile_contents)
      end
    end

    def source(source_file, options = {})
      Scry.add_source(source_file, options)
    end

    def namespace(name, options = {})
      @current_namespace ||= []
      name = name

      options[:current_namespace] = @current_namespace.dup
      Scry.add_namespace(name.to_s.downcase, options)
      if block_given?
        @current_namespace.push name
        yield if block_given?
        @current_namespace.pop
      end
    end

    def param(name, options = {})
      @current_namespace ||= []
      options[:current_namespace] = @current_namespace.dup
      Scry.add_param(name, options)
    end
  end
end

