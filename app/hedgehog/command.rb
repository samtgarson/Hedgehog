module Hedgehog
  class Command
    class Arguments
      def initialize(string)
        @string = string
      end

      def to_s
        @string || ""
      end

      def to_a
        to_s.split(" ")
      end

      def to_i
        to_s.to_i
      end

      def method_missing(sym, *args, &blk)
        to_a.send(sym, *args, &blk)
      end
    end

    def <<(command)
      array = command.split(" ")

      if @original
        @original += "\n" + command
      else
        @original = command
      end

      work_it_out
    end

    def binary_name
      @binary_name
    end

    def binary_path
      @binary_path
    end

    def original
      @original
    end

    def with_binary_path
      [
        env_vars,
        binary_path,
        arguments.to_s
      ].flatten.join(" ")
    end

    # TODO: for spec:
    # echo "hello  world"
    def arguments
      args = if @arguments_range
               original.split(" ", @arguments_range.first + 1)[@arguments_range.first]
             else
               args = ""
             end

      Hedgehog::Command::Arguments.new(args)
    end

    def incomplete?
      last_line_has_backslash_at_end? || !balanced?
    end

    def env_vars
      return [] unless @env_vars_range
      original.split(" ")[@env_vars_range]
    end

    private

    attr_reader :command_parts

    # TODO: for spec:
    # TEST=test ruby -e "puts ENV['TEST']"
    # bash -c "echo test"
    # /bin/bash -c "echo test"
    def work_it_out
      @binary_name = nil
      @binary_path = nil
      @arguments_range = nil
      @env_vars_range = nil

      original.split(" ").each.with_index do |word, index|
        if word.match(/^[\w|-]+$/) || File.file?(word)
          if File.file?(word)
            @binary_name = word.split("/").last
            @binary_path = word
          else
            @binary_name = word
            @binary_path = path_finder.call(binary_name)
          end

          @arguments_range = ((index + 1)..-1)
          @env_vars_range = (0...index) unless index == 0

          return
        end
      end
    end

    def path_finder
      Hedgehog::Settings
        .shared_instance
        .binary_in_path_finder
    end

    def balanced?
      pairs = {
        '{' => '}',
        '[' => ']',
        '(' => ')',
        '`' => '`',
        "'" => "'",
        '"' => '"',
      }

      expectations = []
      original.chars do |char|
        if expectations.last == char
          expectations.pop
          next
        end

        if expectation = pairs[char]
          expectations << expectation
        end
      end

      expectations.empty?
    end

    def last_line_has_backslash_at_end?
      last_line = original.split("\n").compact.last
      return false if last_line.nil?
      last_line.match(/\\\s*$/)
    end
  end
end
