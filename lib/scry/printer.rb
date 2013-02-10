module Scry
  class Printer
    class << self
      def to_s
        self.print
      end

      def print
        puts "---"
        rformat_node(Scry.data, Scry.types, Scry.descriptions)
      end

      private

      def rformat_node(node_data, node_types, node_descriptions, stack = [])
        if node_data.is_a?(Scry::DataNode)
          stack.push Scry::DataNode
          node_data.each do |k,v|
            output = ""
            if v.is_a?(Scry::DataNode)
              (stack.length - 1).times { output += "  " }
              output += "#{k}:"
            else
              lines = {k => v}.to_yaml.split("\n").drop(1)
              whitespace = ""
              (stack.length - 1).times { whitespace += "  " }
              lines.each_with_index do |l,i|
                lines[i] = "#{whitespace}#{l}"
              end
              output = lines.join("\n")
            end
            puts output
            rformat_node(node_data[k], node_types[k] || {}, node_descriptions[k] || {}, stack)
          end
          stack.pop
        end
      end
    end
  end
end
