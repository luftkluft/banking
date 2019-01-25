class CreditCard
  include Store
  attr_reader :current_account
  OPTION_CARDS = { usual: 'usual', capitalist: 'capitalist', virtual: 'virtual' }.freeze

  def initialize(account, type = nil)
    @current_account = account
    save_credit_card(type) if type
  end

  def save_credit_card(type)
    @cards = case type
    when CreditCard::OPTION_CARDS[:usual] then CreditCards::Usual
    when CreditCard::OPTION_CARDS[:capitalist] then CreditCards::Capitalist
    when CreditCard::OPTION_CARDS[:virtual] then CreditCards::Virtual
    end
    save_card(@cards.new.data_card)
  end

  def save_card(cards)
    cards = @current_account.cards << cards
    @current_account.cards = cards
    write_to_file(new_accounts(current_account))
  end

  def destroy_card(answer)
    current_account.cards.delete_at(answer)
    write_to_file(new_accounts(current_account))
  end
end
