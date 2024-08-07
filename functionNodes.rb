####################################
#   CMM FUNCTION                   #
####################################
class CmmFunction < Node
    attr_accessor :type, :params, :codeBlock

    def initialize(type, params = [], codeBlock)
        @type = type
        @params = params
        @codeBlock = codeBlock
    end

    def evaluate(values)
        $scope << {}
        $scope_depth +=1
        replacePossible = false
        values.each_with_index do |value,index|
            if @params[index][@params[0].keys()[index]] == "int" && values[index].class == CmmInteger
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "int" && values[index].evaluate.class == CmmInteger
                value = values[index].evaluate
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "float" && values[index].class == CmmFloat
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "float" && values[index].evaluate.class == CmmFloat
                value = values[index].evaluate
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "bool" && values[index].class == CmmBoolean
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "bool" && values[index].evaluate.class == CmmBoolean
                value = values[index].evaluate
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "char" && values[index].class == CmmChar
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "char" && values[index].evaluate.class == CmmChar
                value = values[index].evaluate
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "string" && values[index].class == CmmString
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "string" && values[index].evaluate.class == CmmString
                value = values[index].evaluate
                replacePossible = true
            end
            if replacePossible
                $scope[$scope_depth][@params[index].keys()[0]] = value
            else
                begin
                    raise(SyntaxError)
                rescue SyntaxError
                    abort("ERROR: faulty parameter, you dumb fuck".red())
                end
            end
        end
        ret = 0
        @codeBlock.each do |x|
            if x.is_a?(ContainerNode) and x.will_return().is_a?(CmmReturn)
                return x.evaluate()
            elsif x.is_a?(CmmReturn)
                return x.evaluate()
            else
                x.evaluate
            end
        end

        $scope_depth -=1
        ret = $scope.pop()
        if ret.is_a?(Hash)
            unless @type == "void"
                abort("ERROR: function does not return a '#{@type}', you dumb fuck".red())
            end
        end
    end
end

####################################
#   CMM RETURN                     #
####################################
class CmmReturn < Node
    attr_accessor :thing, :type, :reset_thing

    def initialize(thing = nil)
        @thing = thing
        @reset_thing = thing
        @type = nil
    end

    def evaluate()
        thing = @thing
        if thing.is_a?(LookUp) or thing.is_a?(ExpressionNode)
            thing = thing.evaluate
            if thing == true
                thing = CmmBoolean.new(true)
            elsif thing == false
                thing = CmmBoolean.new(false)
            end
        end
        case thing
        when CmmInteger
            check = "int"
        when CmmFloat
            check = "float"
        when CmmBoolean
            check = "bool"
        when CmmChar
            check = "char"
        when CmmString
            check = "string"
        when FunctionCall
            check = thing.gettype()
        else
            begin
                raise(SyntaxError)
            rescue SyntaxError
                if thing == nil
                    abort("ERROR: #{@type}-function must '#{@type}', you dumb fuck".red())
                else
                    abort("ERROR: '#{thing}' is not returnable, you dumb fuck".red())
                end
            end
        end
        if @type == "void" and thing != nil
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: void function can not have 'return', you dumb fuck".red())
            end
        end
        if check == @type
            if thing.is_a?(FunctionCall)
                thing.evaluate()
            else
                $scope_depth -=1
                $scope.pop()
                return thing
            end
        else
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: '#{check}' is not of type '#{@type}', you dumb fuck".red())
            end
        end
    end

end

####################################
#   CMM FUNCTION CALL              #
####################################
class FunctionCall < Node
    attr_accessor :name, :params

    def initialize(name, params = [])
        @name = name
        @params = params
    end

    def gettype()
        return $funcs[@name].type
    end

    def evaluate()
        $funcs[@name].codeBlock.each do |x|
            if x.is_a?(ContainerNode)
                x.has_return().each do |c|
                    if c.type == nil
                        c.type = gettype()
                    end
                    c.thing = c.reset_thing
                end
                if x.is_a?(ElifStatment)
                    x.returns = []
                end
            elsif x.is_a?(CmmReturn)
                if x.type == nil
                    x.type = gettype()
                end
                x.thing = x.reset_thing
            end
        end
        $funcs[@name].evaluate(@params)
    end
end

####################################
#   CMM FUNCTION DECLARATION       #
####################################
class FunctionDeclaration < Node
    attr_accessor :identifier, :function

    def initialize(identifier, func)
        @identifier = identifier
        @function = func
    end

    def evaluate()
        $funcs[@identifier] = @function
    end
end


####################################
#   MAIN FUNCTION                  #
####################################
class MainFunction < Node
    attr_accessor :statements

    def initialize(statements)
        @statements = statements
    end

    def evaluate()
        @statements.each do |x|
            x.evaluate()
        end
    end
end
