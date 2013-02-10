module Scry
  class Validations

    class << self
      def run_all
        validate_requirements && validate_types
      end

      private

      # required parameters are defined in the namespace, but have a nil value in the Scry data hash
      def validate_requirements
        violation = find_nil_data_values(Scry.data)
        unless violation.nil?
          errmsg = "ERROR!!!! Missing required parameter in Scry configuration sources!\n"
          desclookup = Scry.descriptions.dup
          depth = 0
          as_yaml = ""
          violation[:namespace].each do |ns|
            (depth*2).times { as_yaml += " " }
            as_yaml += "#{ns}:\n"
            depth += 1
            if desclookup.respond_to?(:has_key?) && desclookup.has_key?(ns)
              desclookup = desclookup[ns]
            else
              desclookup = nil
            end
          end
          (depth*2).times { as_yaml += " " }
          as_yaml += "#{violation[:name]}: your configuration goes here"
          errmsg+= "Parameter:   #{format_key_string(violation[:namespace], violation[:name])}\n"
          errmsg+= "Description: #{desclookup[violation[:name]]}\n"
          errmsg+= "Configured Scry sources:\n"
          Scry.sources.each_with_index do |src,i|
            errmsg+= "#{i+1}. #{src}\n"
          end
          if desclookup.kind_of?(Hash) && desclookup[violation[:name]]
          errmsg += "\n# BEGIN - Example YAML representation of missing parameter\n\n"
          errmsg += as_yaml
          errmsg += "\n\n# END\n"
          end
          raise MissingRequiredParameter, errmsg
        end
        true
      end

      # ensure that all values have a valid type
      def validate_types
        #raise ParameterTypeMismatch, "foo"
        violation = find_type_violation(Scry.types.dup, Scry.data.dup)

        unless violation == nil
          desclookup = Scry.descriptions.dup
          depth = 0
          violation[:namespace].each do |ns|
            depth += 1
            if desclookup.respond_to?(:has_key?) && desclookup.has_key?(ns)
              desclookup = desclookup[ns]
            else
              desclookup = nil
            end
          end
          errmsg = "ERROR!!!! A parameter in the Scry configuration has an invalid type!\n"
          errmsg+= "Parameter:   #{format_key_string(violation[:namespace], violation[:name])}\n"
          errmsg+= "Value:       #{violation[:data]}\n"
          errmsg+= "Found type:  #{violation[:data].class}\n"
          errmsg+= "Expected:    #{violation[:types]}\n"
          errmsg+= "Description: #{desclookup[violation[:name]]}\n"
          errmsg+= "Configured Scry sources:\n"
          Scry.sources.each_with_index do |src,i|
            errmsg+= "#{i+1}. #{src}\n"
          end
          raise ParameterTypeMismatch, errmsg
        end
        true
      end

      def format_key_string(namespace, name)
        if namespace.empty?
          "Scry['#{name}']"
        else
          "Scry['#{namespace.join("']['")}']['#{name}']"
        end
      end

      def find_nil_data_values(node, stack = [])
        if node.is_a?(Hash)
          node.each do |k,v|
            if v.is_a?(Hash)
              stack.push(k)
              v.each do |item|
                if item[1] == nil
                  return {:name => item[0], :namespace => stack}
                else
                  result = find_nil_data_values(v, stack)
                  return result if result
                end
              end
              stack.pop
            else
              if v == nil
                return {:name => k, :namespace => stack}
              end
            end
          end
        end
        nil
      end

      def find_type_violation(type_node, data_node, stack = [])
        if type_node.is_a?(Hash)
          type_node.each do |k,v|
            if v.is_a?(Hash)
              stack.push(k)
              v.each do |item|
                if item[1].is_a?(Class)
                  unless data_node[k][item[0]].is_a?(item[1])
                    violation = { :name => item[0], :data => data_node[k][item[0]], :types => item[1], :namespace => stack }
                    return violation
                  end
                elsif item[1].is_a?(Array)
                  valid = false
                  item[1].each do |i|
                    if i.is_a?(Class)
                      if data_node[k][item[0]].is_a?(i)
                        valid = true
                      end
                    end
                  end
                  unless valid
                    violation = { :name => item[0], :data => data_node[k][item[0]], :types => item[1], :namespace => stack }
                    return violation
                  end
                else
                  result = find_type_violation(v, data_node[k], stack)
                  return result if result
                end
              end
              stack.pop
            else
              if v.is_a?(Class)
                unless data_node[k].is_a?(v)
                  violation = { :name => k, :data => data_node[k], :types => v, :namespace => stack }
                  return violation
                end
              elsif v.is_a?(Array)
                valid = false
                v.each do |i|
                  if i.is_a?(Class)
                    if data_node[k].is_a?(i)
                      valid = true
                    end
                  end
                end
                unless valid
                  violation = { :name => k, :data => data_node[k], :types => v, :namespace => stack }
                  return violation
                end
              end
            end
          end
        end
        nil
      end
    end
  end
end
