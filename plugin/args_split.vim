if exists("g:args_split")
  finish
endif

if !has("ruby")
  echohl ErrorMsg
  echon "Sorry, args_split requires ruby support."
  finish
endif

let g:args_split = "true"

function! ArgsSplit()
  :ruby ArgsSplitter.new.args_split
endfunction

command ArgsSplit :call ArgsSplit()

ruby << EOF

class ArgsSplitter
  def initialize
    @current_buffer = VIM::Buffer.current
    @current_line_number = @current_buffer.line_number
    @current_line = @current_buffer.line
  end

  def args_split
    _add_newlines_to_current_line
    @current_buffer.delete(@current_line_number)
    last_line_number = _write_split_lines
    _align_written_lines(last_line_number)
  end

  def _write_split_lines
    split_lines = @current_line.split("\n")
    new_line_number = nil
    split_lines.each_with_index do |split_line, line_index|
      new_line_number = @current_line_number - 1 + line_index
      @current_buffer.append(new_line_number, split_line)
    end
    new_line_number + 1
  end

  def _add_newlines_to_current_line
    @current_line.sub!("(", "(\n")
    @current_line.gsub!(", ", ",\n")
    @current_line.gsub!(")", "\n)")
  end

  def _align_written_lines(last_line_number)
    VIM::command("normal! #{@current_line_number}G=#{last_line_number}G")
  end
end

EOF

