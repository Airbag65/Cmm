#!/usr/bin/env ruby

require 'logger'

class Rule

    Match = Struct.new :pattern, :block

    def initialize(name, parser)
        @logger = parser.logger
        @name = name
        @parser = parser
        @matches = []
        @lrmatches = []
    end

    def match(*pattern, &block)
        match = Match.new(pattern, block)
        if pattern[0] == @name
            pattern.shift
            @lrmatches << match
        else
            @matches << match
        end
    end

    def parse
        match_result = try_matches(@matches)
        return nil unless match_result
        loop do
            result = try_matches(@lrmatches, match_result)
            return match_result unless result
            match_result = result
        end
    end

    private

    def try_matches(matches, pre_result = nil)
        match_result = nil
        start = @parser.pos
        matches.each do |match|
            result = pre_result ? [pre_result] : []
            match.pattern.each_with_index do |token, index|
                if @parser.rules[token]
                    result << @parser.rules[token].parse
                    unless result.last
                        result = nil
                        break
                    end
                    @logger.debug("Matched '#{@name} = #{match.pattern[index..-1].inspect}'")
                else
                    nt = @parser.expect(token)
                    if nt
                        result << nt
                        if @lrmatches.include?(match.pattern) then
                            pattern = [@name] + match.pattern
                        else
                            pattern = match.pattern
                        end
                        @logger.debug("Matched token '#{nt}' as part of rule '#{@name} <= #{pattern.inspect}'")
                    else
                        result = nil
                        break
                    end
                end
            end
            if result
                if match.block
                    match_result = match.block.call(*result)
                else
                    match_result = result[0]
                end
                @logger.debug("'#{@parser.string[start..@parser.pos - 1]}' matched '#{@name}' and generated '#{match_result.inspect}'") unless match_result.nil?
                break
            else
                @parser.pos = start
            end
        end

        return match_result
    end
end

class Parser

    attr_accessor :pos
    attr_reader :rules, :string, :logger

    class ParseError < RuntimeError; end

    def initialize(language_name, &block)
        @logger = Logger.new(STDOUT)
        @lex_tokens = []
        @rules = {}
        @start = nil
        @language_name = language_name
        instance_eval(&block)
    end

    def tokenize(string)
        @tokens = []
        @string = string.clone
        until string.empty?
            raise ParseError, "unable to lex '#{string}" unless @lex_tokens.any? do |tok|
                match = tok.pattern.match(string)
                if match
                    @logger.debug("Token #{match[0]} consumed")
                    @tokens << tok.block.call(match.to_s) if tok.block
                    string = match.post_match
                    true
                else
                    false
                end # if
            end # raise
        end # until
    end

    def parse(string)
        tokenize(string)
        @pos = 0
        @max_pos = 0
        @expected = []
        result = @start.parse
        if @pos != @tokens.size
            raise ParseError, "Parse error. expected: '#{@expected.join(', ')}', found '#{@tokens[@max_pos]}'"
        end
        return result
    end

    def next_token
        @pos += 1
        return @tokens[@pos - 1]
    end

    def expect(tok)
        t = next_token
        if @pos - 1 > @max_pos
            @max_pos = @pos - 1
            @expected = []
        end
        return t if tok === t
        @expected << tok if @max_pos == @pos - 1 && !@expected.include?(tok)
        return nil
    end

    def to_s
        "Parser for #{@language_name}"
    end

    private

    LexToken = Struct.new(:pattern, :block)

    def token(pattern, &block)
        @lex_tokens << LexToken.new(Regexp.new('\\A' + pattern.source), block)
    end

    def start(name, &block)
        rule(name, &block)
        @start = @rules[name]
    end

    def rule(name, &block)
        @current_rule = Rule.new(name, self)
        @rules[name] = @current_rule
        instance_eval &block
        @current_rule = nil
    end

    def match(*pattern, &block)
        @current_rule.send(:match, *pattern, &block)
    end
end
