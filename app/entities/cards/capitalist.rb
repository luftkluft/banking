class Capitalist < BaseCard
  TAXES = {
    put: 10,
    withdraw: 4,
    sender: 10
  }.freeze

  DEFAULT_BALANCE = 100.0

  def initialize(type)
    @type = type
    @balance = DEFAULT_BALANCE
    super()
  end

  def withdraw_percent_tax
    TAXES[:withdraw]
  end

  def put_fixed_tax
    TAXES[:put]
  end

  def sender_percent_tax
    TAXES[:sender]
  end
end