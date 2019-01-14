class Virtual < BaseCard
  TAXES = {
    put: 1,
    withdraw: 12,
    sender: 1
  }.freeze

  DEFAULT_BALANCE = 150.0

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

  def sender_fixed_tax
    TAXES[:sender]
  end
end
