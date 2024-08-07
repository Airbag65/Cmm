class LinkedList

    attr_accessor :head

    def initialize(vals = [])
        @head = nil
        vals.each do |x|
            append(x)
        end
    end

    def append(value)
        if last() == nil
            @head = Segment.new(value)
        else
            last().next = Segment.new(value)
        end
    end

    def at(index)
        if @head == nil
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: List index out of range, bucko".red())
            end
        end
        if index.is_a?(AritmheticExpression)
            index = index.evaluate().evaluate()
        end
        if index.is_a?(CmmInteger)
            index = index.evaluate()
        end
        follower = @head
        if index == 0
            return follower.seg_value
        end
        for i in (0..index-1) do
            if follower.next == nil
                begin
                    raise(SyntaxError)
                rescue SyntaxError
                    abort("ERROR: List index out of range, bucko".red())
                end
            else
                follower = follower.next
            end
        end
        return follower.seg_value
    end


    def private_at(index)
        if @head == nil
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: List index out of range, bucko".red())
            end
        end
        follower = @head
        if index == 0
            return follower
        end
        if index.is_a?(CmmInteger)
            index = index.evaluate()
        end
        for i in (0..index - 1) do
            if follower.next == nil
                begin
                    raise(SyntaxError)
                rescue SyntaxError
                    abort("ERROR: List index out of range, bucko".red())
                end
            else
                follower = follower.next
            end
        end
        return follower
    end

    def size()
        if @head == nil
            return 0
        else
            counter = 0
            follower = @head
            while true
                if follower == nil
                    return counter
                    break
                else
                    counter += 1
                    follower = follower.next
                end
            end
        end
    end

    def pop()
        seg = last()
        prev = private_at(size()-2)
        prev.next = nil
        return seg.seg_value
    end

    def remove_at(index)
        curr = private_at(index)
        prev = private_at(index-1)
        prev.next = curr.next
    end

    def replace_at(index, val)
        location = private_at(index)
        location.seg_value = val
    end

    def last()
        if @head == nil
            return nil
        else
            follower = @head
            while true
                if follower.next == nil
                    return follower
                    break
                else
                    follower = follower.next
                end
            end
        end
    end

    def print()
        to_print = "["
        if @head == nil
            to_print += "]"
            return to_print
        else
            follower = @head
            while true
                if follower.seg_value.is_a?(LookUp) || follower.seg_value.is_a?(AritmheticExpression)
                    to_print += follower.seg_value.evaluate().evaluate().to_s()
                else
                    to_print += follower.seg_value.evaluate().to_s()
                end
                if follower.next == nil
                    to_print += "]"
                    break
                else
                    to_print += ", "
                    follower = follower.next
                end
            end
        end

        return to_print
    end

    def to_s
        to_print = ""
        if @head == nil
            to_print += ""
            return to_print
        else
            follower = @head
            while true
                to_print += follower.seg_value
                if follower.next == nil
                    break
                else
                    follower = follower.next
                end
            end
        end
        return to_print
    end

    def conc(val)
        if val.is_a?(LookUp)
            val = val.evaluate()
        end
        if val.is_a?(ListNode)
            val.generate_list()
        end
        follower = val.list.head
        while true
            append(follower.seg_value)
            if follower.next.nil?
                break
            end
            follower = follower.next
        end
    end
end

class Segment

    attr_accessor :seg_value, :next

    def initialize(value, n = nil)
        @seg_value = value
        @next = n
    end
end
