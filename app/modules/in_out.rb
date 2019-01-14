module InOut
  def input
    gets.chomp
  end

  def output(text)
    return puts text if text.is_a?(String)

    text.each do |line|
      puts line
    end
  end
end
