class Usual < BaseCard
  def initialize
    @type = 'usual'
    @balance = 50
    super()
  end

  def put_percent_tax
    2
  end

  def withdraw_percent_tax
    5
  end

  def sender_fixed_tax
    20
  end
end
