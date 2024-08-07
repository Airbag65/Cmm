#!/usr/bin/env ruby

$scope = [{}]
$scope_depth = 0

$funcs = {}

####################################
#     NODE (BASECLASS)             #
####################################
class Node
    def evaluate()
    end
end

####################################
#    EXPRESSION NODE               #
####################################
class ExpressionNode < Node
    def evaluate()
    end
end

####################################
#   ARITHMETIC EXPRESSION          #
####################################
class AritmheticExpression < ExpressionNode
    attr_reader :lhs, :op, :rhs
    def initialize(lhs, op, rhs)
        @lhs = lhs
        @op = op
        @rhs = rhs
    end

    def evaluate()
        lhtemp = @lhs
        while lhtemp.is_a?(Node)
            lhtemp = lhtemp.evaluate()
        end
        rhtemp = @rhs
        while rhtemp.is_a?(Node)
            rhtemp = rhtemp.evaluate()
        end
        result = eval("#{lhtemp}#{@op}#{rhtemp}")
        if result.is_a?(Integer)
            return CmmInteger.new(result)
        elsif result.is_a?(Float)
            return CmmFloat.new(result)
        end
    end
end


####################################
#   CMM FLOAT                      #
####################################
class CmmFloat < Node

    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end
end

####################################
#   CMM INTEGER                    #
####################################
class CmmInteger < Node

    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end

####################################
#   BINARY EXPRESSION              #
####################################
class BinaryExpression < ExpressionNode
    attr_reader :lhs, :op, :rhs

    def initialize(lhs, op, rhs)
        @lhs = lhs
        @op = op
        @rhs = rhs
    end

    def evaluate()
        lhtemp = @lhs
        while lhtemp.is_a?(Node)
            lhtemp = lhtemp.evaluate()
        end
        rhtemp = @rhs
        while rhtemp.is_a?(Node)
            rhtemp = rhtemp.evaluate()
        end
        return eval("#{lhtemp}#{@op}#{rhtemp}")
    end
end

####################################
#      UNARY EXPRESSION            #
####################################
class UnaryExpression < ExpressionNode
    attr_accessor :expr

    def initialize(value)
        @expr = value
    end

    def evaluate()
        return @expr.evaluate()
    end
end

####################################
#   CMM BOOLEAN                    #
####################################
class CmmBoolean < Node
    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end

####################################
#   CMM FUNCTION                   #
####################################
class CmmFunction < Node
    attr_accessor :type, :params, :codeBlock

    def initialize(type, params, codeBlock)
        @type = type
        @params = params
        @codeBlock = codeBlock
    end

    def evaluate(values)
        $scope << {}
        $scope_depth +=1
        replacePossible = false

        #p values[0].evaluate
        values.each_with_index do |value,index|
            if @params[index][@params[0].keys()[index]] == "int" && values[index].class == CmmInteger
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "int" && values[index].evaluate.class == CmmInteger
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "float" && values[index].class == CmmFloat
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "float" && values[index].evaluate.class == CmmFloat
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "bool" && values[index].class == CmmBoolean
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "bool" && values[index].evaluate.class == CmmBoolean
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
        @codeBlock.each do |x|
            if x.is_a?(CmmReturn)

                return x.evaluate(@type)
                break
            end
            x.evaluate()
        end
        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#   CMM RETURN                     #
####################################
class CmmReturn < Node
    attr_accessor :thing

    def initialize(thing)
        @thing = thing
    end

    def evaluate(type)
        if @thing.is_a?(LookUp) or @thing.is_a?(ExpressionNode)
            @thing = @thing.evaluate
            if @thing == true
                @thing = CmmBoolean.new(true)
            elsif @thing == false
                @thing = CmmBoolean.new(false)
            end
        end
        case @thing
        when CmmInteger
            check = "int"
        when CmmFloat
            check = "float"
        when CmmBoolean
            check = "bool"
        else
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: incorrect return type, you dumb fuck".red())
            end
        end
        if check == type
            return @thing
        end
    end

end

####################################
#   CMM FUNCTION CALL              #
####################################
class FunctionCall < Node
    attr_accessor :name, :params

    def initialize(name, params)
        @name = name
        @params = params
    end

    def gettype()
        return $funcs[@name].type
    end

    def evaluate()
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
#   PRINT                          #
####################################
class Print < Node
    attr_accessor :val

    def initialize(val)
        @val = val
    end

    def evaluate()
        temp = @val
        while temp.is_a?(Node)
            temp = temp.evaluate()
        end
        puts temp
        return temp
    end
end

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
        case @type
        when "int"
            typecheck(CmmInteger)
        when "float"
            typecheck(CmmFloat)
        when "bool"
            typecheck(CmmBoolean)
        end
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
            if temp.class == CmmInteger || temp.class == CmmFloat
                break
            elsif temp.evaluate.class != CmmInteger || temp.evaluate.class != CmmFloat
                temp = temp.evaluate
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

####################################
#   IF STATEMENT                   #
####################################
class IfStatement < Node
    attr_accessor :expr, :local_bumpster
    def initialize(a,b)
        @expr = a
        @local_bumpster = b
    end

    def evaluate()
        $scope << {}
        $scope_depth += 1
        if @expr.evaluate()
            @local_bumpster.each() do |x|
                x.evaluate()
            end
        end
        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#   ELSE IF STATEMENT              #
####################################
class ElifStatment < Node
    attr_accessor :expr, :local_bumpster, :next_elif

    def initialize(expr, bumpster, elif = nil)
        @expr = expr
        @local_bumpster = bumpster
        @next_elif = elif
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        if @expr.evaluate()
            @local_bumpster.each() do |x|
                x.evaluate()
            end
        elsif @next_elif != nil
            @next_elif.evaluate()
        end
        $scope_depth -=1
        $scope.pop()
    end

end

####################################
#   ELSE STATEMENT                 #
####################################
class ElseStatment < Node
    attr_accessor :bumpster

    def initialize(bumpster)
        @local_bumpster = bumpster
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        @local_bumpster.each() do |x|
            x.evaluate()
        end
        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#       WHILE LOOP                 #
####################################
class WhileLoop < Node
    attr_accessor :expr, :bumpster

    def initialize(expr, bumpster)
        @expr = expr
        @local_bumpster = bumpster
    end

    def evaluate()
        broken = false
        $scope << {}
        $scope_depth +=1
        $scope[$scope_depth]["42069_looper"] = {"break" => false}
        while @expr.evaluate()
            @local_bumpster.each() do |x|
                x.evaluate()
                if $scope[$scope_depth]["42069_looper"]["break"]
                    broken = true
                    break
                end
            end
            if broken
                break
            end
        end

        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#       FOR LOOP                   #
####################################
class ForLoop < Node
    attr_accessor :var, :expr, :creme, :blocks

    def initialize(var, expr, creme, blocks)
        @var = var
        @expr = expr
        @creme = creme
        @blocks = blocks
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        @var.evaluate()
        @blocks << @creme
        loopObj = WhileLoop.new(@expr, @blocks)
        loopObj.evaluate()
    end
end
####################################
#       CMM BREAK                  #
####################################
class CmmBreak
    def initialize()
    end

    def evaluate()
        index = $scope_depth
        while index >= 0
            if $scope[index]["42069_looper"]
                $scope[index]["42069_looper"]["break"] = true
                break
            else
                index -= 1
            end
        end
    end
end
####################################
#       INCREMENT                  #
####################################
class Increment < Node
    attr_accessor :value

    def initialize(value)
        @value = value
    end

    def evaluate()
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate + 1).evaluate()
        else
            @value.value = @value.value + 1
        end
    end
end

####################################
#       DECREMENT                  #
####################################
class Decrement < Node
    attr_accessor :value

    def initialize(value)
        @value = value
    end

    def evaluate()
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate - 1).evaluate()
        else
            @value.value = @value.value - 1
        end
    end
end


class String
    def red
    "\e[31m#{self}\e[0m"
    end
end
