module CanCan
  class Rule
    def matches_conditions_hash?(subject, conditions = @conditions)
      if conditions.empty?
        true
      else
        if model_adapter(subject).override_conditions_hash_matching? subject, conditions
          model_adapter(subject).matches_conditions_hash? subject, conditions
        else
          conditions.all? do |name, value|
            if model_adapter(subject).override_condition_matching? subject, name, value
              model_adapter(subject).matches_condition? subject, name, value
            else
              attribute = subject.send(name)
              if value.kind_of?(Hash)
                if attribute.kind_of?(Array) || attribute.kind_of?(ActiveRecord::Relation)
                  attribute.any? { |element| matches_conditions_hash? element, value }
                else
                  !attribute.nil? && matches_conditions_hash?(attribute, value)
                end
              elsif !value.is_a?(String) && value.kind_of?(Enumerable)
                value.include? attribute
              else
                attribute == value
              end
            end
          end
        end
      end
    end 
  end 
end 
