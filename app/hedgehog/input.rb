module Hedgehog
  class Input
    def await_user_input
      @show_prompt = true
      while true
        command_string = editor.read(get_prompt, true)

        # CMD+D makes nil for some reason
        exit if command_string.nil?

        result = runner.run(command_string)
        @show_prompt = result
      end
    rescue Interrupt
      puts ""
      Hedgehog::Input.new.await_user_input
    end

    private

    def editor
      @editor ||= Rawline::Editor.new
    end

    def get_prompt
      if @show_prompt
        prompt.call
      else
        colorless = prompt.call.gsub(/\e\[(\d+)(;\d+)*m/, "").gsub("\e[m", "")
        " " * colorless.length
      end
    end

    def runner
      @runner ||= Hedgehog::Execution::Runner.new
    end
  end
end
