# !/usr/bin/env ruby
require_relative './rdparse'
require_relative './requireNodes'


class CMM

    def initialize()

        @cmmParser = Parser.new("CMM") do
            token(/\s+/)
            token(/[0-9]*\.[0-9]+/) { |x| x }
            token(/[\w|:|ä|Ä|å|Å|ö|Ö|!]+/) { |x| x }
            token(/;/) { |x| x }
            token(/True/) { |x| x }
            token(/False/) { |x| x }
            token(/\/\/.*$/)
            token(/#.*$/)
            token(/./) { |x| x }


            start :program do
                match(:func_declares) do |x|
                    x.each do |c|
                        c.evaluate()
                    end
                end
            end


            rule :func_declares do
                match(:func_declares, :func_declare) do |x,c|
                    x << c
                    x
                end
                match(:func_declare) { |x| [x] }
            end

            rule :func_declare do
                match(:main) { |x| MainFunction.new(x)}
                match(:new_function) {|x| x }
            end

            rule :main do
                match('void', /codeGoBrr[r]+/, '(', ')', '{', '}') { [] }
                match('void', /codeGoBrr[r]+/, '(', ')', '{', :code_blocks, '}') { |_, _, _, _, _, x, _| x }
            end

            rule :new_function do
                match(:type, :identifier, '(', :params, ')', '{', :code_blocks, '}') do |type,identifier,_,params,_,_,blocks,_|
                    FunctionDeclaration.new(identifier, CmmFunction.new(type, params, blocks))
                end
                match(:type, :identifier, '(', ')', '{', :code_blocks, '}') do |type,identifier,_,_,_,blocks,_|
                    FunctionDeclaration.new(identifier, CmmFunction.new(type, blocks))
                end
            end

            rule :code_blocks do
                match(:code_blocks, :code_block) do |x, c|
                    if c.class == Array
                        x.concat(c)
                    else
                        x << c
                    end
                    x
                end
                match(:code_block) { |x| [x] }
            end

            rule :code_block do
                match(:increment, ';')
                match(:decrement, ';')
                match(:multiment, ';')
                match(:diviment, ';')
                match(:potensiment, ';')
                match(:list_opp, ';')
                match(:string_opp, ';')
                match(:input, ';')
                match(:assign, ';')
                match(:print)
                match(:if_statement)
                match(:change_var)
                match(:while_loop)
                match(:for_loop)
                match(:call_function, ';')
                match(:break)
                match(:return, ';')

            end


            rule :input do
                match('input', '(', ')') do |_,_,_|
                    CmmInput.new("int")
                end
            end

            rule :call_function do
                match(:identifier, '(', :values, ')') do |name,_,params,_,_|
                    FunctionCall.new(name, params)
                end
                match(:identifier, '(', ')') do |name,_,_|
                    FunctionCall.new(name)
                end
            end

            rule :return do
                match('return', :value) { |_,x| CmmReturn.new(x)}
                match('return', :if_expr) { |_,x| CmmReturn.new(x)}
                match('return') { |_| CmmReturn.new()}
            end

            rule :assign do
                match(:type, :identifier, '=', 'input', '(', ')') do |type,id,_,_,_,_|
                    Assignment.new(id, CmmInput.new(type), type)
                end
                match(:type, :identifier, '=', :call_function) do |type, identifier, _, value|
                    Assignment.new(identifier, value, type)
                end
                match(:type, :identifier, '=', :value) do |type, identifier, _, value|
                    Assignment.new(identifier, value, type)
                end
                match('array', '<', :type, '>', :identifier, '=', :value) do |_,_,type,_,identifier,_,value|
                    Assignment.new(identifier, ListNode.new(value, type), "array")

                end
                match('array', '<', :type, '>', :identifier, '=', '[',']') do |_,_,type,_,identifier,_,_,_|
                    Assignment.new(identifier, ListNode.new([], type), "array")
                end

            end

            rule :list_opp do
                match(:identifier, '[', :index_opp, ']', '=', :value) do |id,_,x,_,_,val|
                    ListOpp.new(LookUp.new(id), x, "replace", val)
                end
                match(:identifier, '[', :index_opp, ']') do |id,_,x,_|
                    ListOpp.new(LookUp.new(id), x, "index")
                end
                match(:identifier, '.','append','(', :value, ')') do |id,_,_,_,x,_|
                    ListOpp.new(LookUp.new(id), x, "append")
                end
                match(:identifier, '.','pop','(',')') do |id,_,_,_,_|
                    ListOpp.new(LookUp.new(id), 0, "pop")
                end
                match(:identifier, '.','size','(',')') do |id,_,_,_,_|
                    ListOpp.new(LookUp.new(id), 0, "size")
                end
                match(:identifier, '.','conga','(', :value, ')') do |id,_,_,_,x,_|
                    ListOpp.new(LookUp.new(id), x, "conc")
                end
            end

            rule :index_opp do
                match(Integer) { |x| x }
                match(:value) { |x| x }
            end

            rule :string_opp do
                match(:identifier, '[', :index_opp, ']') do |id,_,x,_|
                    StringOpp.new(LookUp.new(id), x, "index")
                end
                match(:identifier, '.','size','(',')') do |id,_,_,_,_|
                    StringOpp.new(LookUp.new(id), 0, "size")
                end
                match(:identifier, '.','conga','(', :value, ')') do |id,_,_,_,x,_|
                    StringOpp.new(LookUp.new(id), x, "conc")
                end
            end


            rule :change_var do
                match(:identifier, '=', :value, ';') do |identifier, _, new_value, _|
                    ChangeVariable.new(identifier, new_value)
                end
            end

            rule :if_statement do
                match('if', '(', :if_expr, ')', '{', :code_blocks, '}', :else_statement) do |_,_,a,_,_,b,_,c|
                    ElifStatment.new(a,b,c)
                end
                match('if', '(', :if_expr, ')', '{', :code_blocks, '}', :elif_statements) do |_,_,a,_,_,b,_,c|
                    ElifStatment.new(a,b,c)
                end
                match('if', '(', :if_expr, ')', '{', :code_blocks, '}') do |_,_,a,_,_,b,_|
                    IfStatement.new(a, b)
                end

            end

            rule :if_expr do
                match(:value, :operator, :value) do |val1, op, val2|
                    BinaryExpression.new(val1, op, val2)
                end
                match(:value) do |bool|
                    UnaryExpression.new(bool)
                end
            end

            rule :else_statement do
                match('else', '{', :code_blocks, '}') do |_,_,a,_|
                    ElseStatment.new(a)
                end
            end

            rule :elif_statements do
                match(:elif_statements, :elif_statement) do |a,b|
                    a.next_elif = b
                end
                match(:elif_statement) do |a|
                    a
                end

            end

            rule :elif_statement do
                match('elif', '(', :if_expr, ')', '{', :code_blocks, '}', :elif_statement) do |_,_,a,_,_,b,_,c|
                    ElifStatment.new(a,b,c)
                end
                match('elif', '(', :if_expr, ')', '{', :code_blocks, '}', :else_statement) do |_,_,a,_,_,b,_,c|
                    ElifStatment.new(a,b,c)
                end
                match('elif', '(', :if_expr, ')', '{', :code_blocks, '}') do |_,_,a,_,_,b,_|
                    ElifStatment.new(a,b)
                end

            end

            rule :while_loop do
                match('while', '(', :if_expr, ')', '{', :code_blocks, '}') do |_,_,a,_,_,b,_|
                    WhileLoop.new(a,b)
                end
            end

            rule :for_loop do
                match('for', '(', :assign, ';', :if_expr, ';', :increment, ')', '{', :code_blocks, '}') do |_,_,assign,_,expr,_,increment,_,_,blocks,_|
                    blocks << increment
                    ForLoop.new(assign, expr, blocks)
                end
                match('for', '(', :assign, ';',:if_expr, ';', :decrement, ')', '{', :code_blocks, '}') do |_,_,assign,_,expr,_,decrement,_,_,blocks,_|
                    blocks << decrement
                    ForLoop.new(assign, expr, blocks)
                end
            end

            rule :break do
                match('break', ';') { |_,_| CmmBreak.new() }
            end

            rule :increment do
                match(:value, '+', '+') do |a,_,_|
                    Increment.new(a)
                end
                match(:value, '+', '=', :num) do |a,_,_,b|
                    Increment.new(a,b)
                end
            end

            rule :decrement do
                match(:value, '-', '-') do |a,_,_|
                    Decrement.new(a)
                end
                match(:value, '+', '=', :num) do |a,_,_,b|
                    Decrement.new(a,b)
                end
            end

            rule :multiment do
                match(:value, '*', '=', :num) do |a,_,_,b|
                    Multiment.new(a,b)
                end
            end

            rule :diviment do
                match(:value, '/', '=', :num) do |a,_,_,b|
                    Diviment.new(a,b)
                end
            end

            rule :potensiment do
                match(:value, '*', '*', '=', :num) do |a,_,_,_,b|
                    Potensiment.new(a,b)
                end
            end

            rule :operator do
                match("=","=") { |a, b| "#{a}#{b}" }
                match("!","=") { |a, b| "#{a}#{b}" }
                match("<","=") { |a, b| "#{a}#{b}" }
                match(">","=") { |a, b| "#{a}#{b}" }
                match("<") { |x| x }
                match(">") { |x| x }
                match("%") { |x| x }
                match("&","&") { |a, b| "and" }
                match("|","|") { |a, b| "or" }
            end

            rule :print do
                match("print", "(", "\"", "\"", ")", ";") do |_,_,_,_,_|
                    Print.new("")
                end
                match("print", "(", ")", ";") do |_,_,_,|
                    Print.new("")
                end
                match('print', '(', :value, ')', ';') do |_, _, x, _, _|
                    Print.new(x)
                end
            end

            rule :params do
                match(:params, ',', :haram) do |x,_,c|
                    x << c
                    x
                end
                match(:haram) {|x| [x]}
                match(""){|_| []}
            end

            rule :haram do
                match(:type, :identifier) {|a,b| {b => a}}
            end

            rule :type do
                match("int") { |x| x }
                match("float") { |x| x }
                match("bool") { |x| x }
                match("char") { |x| x }
                match("string") { |x| x }
                match("void") { |x| x }
            end

            rule :values do
                match(:values, ',', :value) do |a,_,b|
                    a << b
                    a
                end
                match(:value) do |x|
                    [x]
                end
            end

            rule :value do
                match(:boolean) { |x| x }
                match(:comp) { |x| x }
                match('[', :comps, ']') {|_,x,_| x}
            end

            rule :boolean do
                match("True") { CmmBoolean.new(true) }
                match("False") { CmmBoolean.new(false) }
            end

            rule :identifier do
                match(/[a-z]+[\w]*/)
            end

            rule :comps do
                match(:comps, ',', :comp) do |x,_,c|
                    x << c
                    x
                end
                match(:comp) { |x| [x] }
            end

            rule :comp do
                match(:comp, '<', :expr) { |a,_,b| BinaryExpression.new(a, '<', b)}
                match(:comp, '>', :expr) { |a,_,b| BinaryExpression.new(a, '>', b)}
                match(:comp, '<','=', :expr) { |a,_,_,b| BinaryExpression.new(a, "<=", b)}
                match(:comp, '>','=', :expr) { |a,_,_,b| BinaryExpression.new(a,">=", b)}
                match(:comp, '=','=', :expr) { |a,_,_,b| BinaryExpression.new(a,"==", b)}
                match(:comp, '!', '=', :expr){ |a,_,_,b| BinaryExpression.new(a,"!=", b)}
                match(:comp, '&','&', :expr) { |a,_,_,b| BinaryExpression.new(a,"and", b)}
                match(:comp, '|','|', :expr) { |a,_,_,b| BinaryExpression.new(a, "or", b)}
                match(:expr)
            end

            rule :expr do
                match(:expr, '+', :term) { |a, _, b| AritmheticExpression.new(a, '+', b) }
                match(:expr, '-', :term) { |a, _, b| AritmheticExpression.new(a, '-', b) }
                match(:term)
            end

            rule :term do
                match(:term, '*', :expo) { |a, _, b| AritmheticExpression.new(a, '*', b) }
                match(:term, '/', :expo) { |a, _, b| AritmheticExpression.new(a, '/', b) }
                match(:term, '%', :expo) { |a, _, b| AritmheticExpression.new(a, '%', b) }
                match(:expo)
            end

            rule :expo do
                match(:num, '*', '*', :expo) { |a, _, _, b| AritmheticExpression.new(a, '**', b) }
                match(:expo, '*', '*', :expo) { |a, _, _, b| AritmheticExpression.new(a, '**', b) }
                match(:num)
            end


            rule :num do
                match(:call_function) { |x| x }
                match(/[0-9]*\.[0-9]+/) { |x| CmmFloat.new(x.to_f) }
                match(/\d+/) { |x| CmmInteger.new(x.to_i) }
                match('-', /\d+/) { |_,x| CmmInteger.new(x.to_i * -1)}
                match('-', /\d+/, '.',/\d+/) { |_,x,_,y| CmmFloat.new(eval("#{x}.#{y}").to_f * -1)}
                match(:list_opp) { |x| x }
                match(:identifier) { |a| LookUp.new(a) }
                match("'", /\w{1}/, "'") { |_,x,_| CmmChar.new(x) }
                match("\"", :string, "\"") { |_,x,_| CmmString.new(x) }
                match('(', :comp, ')') { |_, a, _| a }

            end

            rule :string do
                match(:string, :string_part) do |x,c|
                    x += " "
                    x += c
                    x
                end
                match(:string_part) { |x| x }
            end

            rule :string_part do
                match("") { |_| "" }
                match(/[^\s"]+/) { |x| x }
            end
        end
    end

    def parse(str)
        @cmmParser.parse(str)
    end

    def log(state = false)
        if state
            @cmmParser.logger.level = Logger::DEBUG
        else
            @cmmParser.logger.level = Logger::WARN
        end
    end
end

c_minus_minus = CMM.new()
c_minus_minus.log()
cmmFile = File.read(ARGV[0])
c_minus_minus.parse(cmmFile)
