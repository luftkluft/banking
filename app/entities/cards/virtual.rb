class Virtual < BaseCard
  def initialize
    @type = 'virtual'
    @balance = 150.0
    super()
  end

  def withdraw_percent_tax
    12
  end

  def put_fixed_tax
    1
  end

  def sender_fixed_tax
    1
  end
end
