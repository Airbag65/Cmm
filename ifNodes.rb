class ContainerNode < Node
    def initialize()
    end

    def has_return()
        @local_bumpster.each() do |x|
            if x.is_a?(CmmReturn)
                return [x]
            elsif x.is_a?(ContainerNode)
                return x.has_return()
            end
        end
        return []
    end

    def will_return()
        if @expr.evaluate()
            @local_bumpster.each() do |x|
                if x.is_a?(CmmReturn)
                    return x
                elsif x.is_a?(ContainerNode)
                    return x.will_return()
                end
            end
        end
    end
end

####################################
#   IF STATEMENT                   #
####################################
class IfStatement < ContainerNode
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
                if x.is_a?(CmmReturn)
                    return x
                elsif x.is_a?(ContainerNode) and x.will_return().is_a?(CmmReturn)
                    $scope_depth -= 1
                    $scope.pop()
                    return x.evaluate()
                else
                    x.evaluate()
                end
            end
        end
        $scope_depth -=1
        $scope.pop()
    end
end


####################################
#   ELSE IF STATEMENT              #
####################################
class ElifStatment < ContainerNode
    attr_accessor :expr, :local_bumpster, :next_elif, :returns

    def initialize(expr, bumpster, elif = nil)
        @expr = expr
        @local_bumpster = bumpster
        @next_elif = elif
        @@returns = []
    end

    def has_return()
        found = false
        @local_bumpster.each() do |x|
            if x.is_a?(CmmReturn)
                @@returns << x
            end
        end
        if @next_elif != nil
            if @next_elif.is_a?(ElseStatment)
                @@returns.concat(@next_elif.has_return())
            else
                @next_elif.has_return()
            end
        end
        return @@returns
    end

    def will_return()
        if @expr.evaluate()
            @local_bumpster.each() do |x|
                if x.is_a?(CmmReturn)
                    return x
                elsif x.is_a?(ContainerNode)
                    return x.will_return()
                end
            end
        else

            if @next_elif != nil
                return @next_elif.will_return()
            end
        end
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        if @expr.evaluate()
            @local_bumpster.each() do |x|
                if x.is_a?(CmmReturn)
                    return x
                elsif x.is_a?(ContainerNode) and x.will_return().is_a?(CmmReturn)
                    $scope_depth -= 1
                    $scope.pop()
                    return x.evaluate()
                else
                    x.evaluate()
                end
            end
        elsif @next_elif != nil
            if @next_elif.will_return().is_a?(CmmReturn)
                return @next_elif.evaluate()
            else
                @next_elif.evaluate()
            end
        end
        $scope_depth -=1
        $scope.pop()
    end

end

####################################
#   ELSE STATEMENT                 #
####################################
class ElseStatment < ContainerNode
    attr_accessor :bumpster

    def initialize(bumpster)
        @local_bumpster = bumpster
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        @local_bumpster.each() do |x|
            if x.is_a?(CmmReturn)
                return x
            elsif x.is_a?(ContainerNode) and x.will_return().is_a?(CmmReturn)
                $scope_depth -= 1
                $scope.pop()
                return x.evaluate()
            else
                x.evaluate()
            end
        end
        $scope_depth -=1
        $scope.pop()
    end

    def will_return()
        @local_bumpster.each() do |x|
            if x.is_a?(CmmReturn)
                return x
            elsif x.is_a?(ContainerNode)
                return x.will_return()
            end
        end
    end
end
