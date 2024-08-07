####################################
#   ASSIGNMENT                     #
####################################
class Assignment < Node
    attr_accessor :identifier, :value, :type

    def initialize(identifier, val, type)
        @identifier = identifier
        @value = val
        @type = type
    end

    def typecheck(cmmtype)
        if @value.is_a?(ExpressionNode)
            if @value.evaluate().is_a?(cmmtype)
                $scope[$scope_depth][@identifier] = @value.evaluate()
            else
                begin
                    raise(SyntaxError)
                rescue SyntaxError
                    abort("ERROR: '#{@value.evaluate().evaluate()}' is not of type '#{@type}', you dumb fuck".red())
                end
            end
        elsif @value.is_a?(FunctionCall)
            if @value.gettype() == @type
                $scope[$scope_depth][@identifier] = @value.evaluate()
            else
                begin
                    raise(SyntaxError)
                rescue SyntaxError
                    abort("ERROR: '#{@value.evaluate().evaluate()}' is not of type '#{@type}', you dumb fuck".red())
                end
            end
        else
            if @value.is_a?(cmmtype)
                $scope[$scope_depth][@identifier] = @value
            else
                begin
                    raise(SyntaxError)
                rescue SyntaxError
                    abort("ERROR: '#{@value.evaluate()}' is not of type '#{@type}', you dumb fuck".red())
                end
            end
        end
    end

    def evaluate()
        if @value.is_a?(CmmInput)
            @value = @value.evaluate()
        end
        case @type
        when "int"
            typecheck(CmmInteger)
        when "float"
            typecheck(CmmFloat)
        when "bool"
            typecheck(CmmBoolean)
        when "char"
            typecheck(CmmChar)
        when "string"
            typecheck(CmmString)
        when "array"
            $scope[$scope_depth][@identifier] = @value
        end
    end
end

####################################
#   LOOK UP                        #
####################################
class LookUp < Node

    attr_accessor :identifier

    def initialize(identifier)
        @identifier = identifier
    end

    def evaluate()
        index = $scope_depth
        temp = nil
        while index >= 0
            if $scope[index][@identifier]
                temp = $scope[index][@identifier]
                break
            else
                index -= 1
            end
        end
        if temp.nil?
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: The variable '#{@identifier}' does not exist, you dumb fuck".red)
            end
        end
        while true
            if temp.class == CmmInteger || temp.class == CmmFloat || temp.class == CmmChar ||
                temp.class == ListNode || temp.class == CmmString || temp.class == CmmBoolean
                break
            elsif temp.evaluate().class != CmmInteger || temp.evaluate().class != CmmFloat ||
                 temp.evaluate().class != CmmChar || temp.evaluate().class != ListNode ||
                 temp.evaluate().class != CmmString || temp.evaluate().class != CmmBoolean
                temp = temp.evaluate()
            end
        end

        return temp
    end
end

####################################
#   CHANGE VARIABLE                #
####################################
class ChangeVariable < Node
    attr_accessor :var, :value

    def initialize(var, value)
        @var = var
        @value = value
    end

    def evaluate()
        index = $scope_depth
        while index >= 0
            if $scope[index][@var]
                if $scope[index][@var].value.class == @value.class
                    $scope[index][@var].value = @value
                else
                    $scope[index][@var].value = @value.evaluate()
                end
                break
            else
                index -= 1
            end
        end

    end

end
