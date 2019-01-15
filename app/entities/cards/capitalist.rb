class Capitalist < BaseCard
  def initialize
    @type = 'capitalist'
    @balance = 100.0
    super()
  end

  def withdraw_percent_tax
    4
  end

  def put_fixed_tax
    10
  end

  def sender_percent_tax
    10
  end
end
