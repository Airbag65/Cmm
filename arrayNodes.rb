####################################
#   LIST NODE                      #
####################################
class ListNode < Node
    attr_accessor :list, :type

    def initialize(vals, type)
        @vals = vals
        @type = type
    end

    def typecheck()
        case @type
        when "int"
            checker(CmmInteger)
        when "float"
            checker(CmmFloat)
        when "bool"
            checker(CmmBoolean)
        when "char"
            checker(CmmChar)
        end
        return LinkedList.new(@vals)
    end

    def checker(cmmtype)
        @vals.each do |x|
            if x.is_a?(ExpressionNode) or x.is_a?(LookUp)
                if x.evaluate().is_a?(cmmtype)
                    next
                else
                    begin
                        raise(SyntaxError)
                    rescue SyntaxError
                        abort("ERROR: List of wrong type, bitch".red())
                    end
                end
            else
                if x.is_a?(cmmtype)
                    next
                else
                    begin
                        raise(SyntaxError)
                    rescue SyntaxError
                        abort("ERROR: List is of wrong type, bitch".red())
                    end
                end
            end
        end
    end

    def generate_list()
        @list = typecheck()
    end

    def evaluate()
        if !@list
            generate_list()
        end
        return @list.print()
    end

end

####################################
#   LIST OPP                       #
####################################
class ListOpp < Node
    attr_accessor :identifier, :index, :op, :list, :new_val

    def initialize(identifier, index, op, new_val = 0)
        @identifier = identifier
        @index = index
        @op = op
        @new_val = new_val
    end

    def evaluate()
        @list = @identifier.evaluate()
        if !@list.list
            @list.evaluate()
        end
        case @op
        when "index"
            @list.list.at(@index)
        when "append"
            @list.list.append(@index)
        when "pop"
            @list.list.pop()
        when "size"
            @list.list.size()
        when "conc"
            @list.list.conc(@index)
        when "replace"
            @list.list.replace_at(@index, @new_val)
        end
    end

end

####################################
#   CMM STRING                     #
####################################
class CmmString < Node
    attr_accessor :list, :vals

    def initialize(vals)
        @vals = vals
        temp = @vals.chars
        @list = LinkedList.new(temp)
    end

    def evaluate()
        @list.to_s()
    end

end

####################################
#   STRING OPP                     #
####################################
class StringOpp < Node
    attr_accessor :identifier, :index, :op

    def initialize(identifier, index, op)
        @identifier = identifier
        @index = index
        @op = op
    end

    def evaluate()
        @string = @identifier.evaluate()
        case @op
        when "index"
            @string.list.at(@index)
        when "size"
            @string.list.size()
        when "conc"
            @string.list.conc(@index)
        end
    end

end
