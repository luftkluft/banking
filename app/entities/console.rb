class Console
  COMMANDS = { create: 'create', load: 'load', accept: 'y', exit: 'exit', show_cards: 'SC',
               delete_account: 'DA', card_create: 'CC', card_destroy: 'DC', put_money: 'PM',
               withdraw_money: 'WM', send_money: 'SM' }.freeze
  include InOut
  include Uploader
  attr_accessor :account

  def initialize(account)
    @account = account
  end

  def console
    message(:hello_message)
    case input
    when COMMANDS[:create] then create
    when COMMANDS[:load] then load
    else exit
    end
  end

  def create
    init_account
    return output(@account.errors.join("\n")) unless @account.valid?

    update_db(@account)
  end

  def init_account
    @account.name = name_input
    @account.age = age_input
    @account.login = login_input
    @account.password = password_input
  end

  def load
    loop do
      accounts = load_db
      return create_the_first_account if accounts.none?

      message(:put_login)
      login = input
      message(:put_passw)
      password = input
      if accounts.map { |account| { login: account.login, password: account.password } }.include?(login: login, password: password)
        @account = accounts.detect { |account| login == account.login }
        main_menu
        break
      else
        message(:credentials)
      end
      return console if (login || password) == COMMANDS[:exit]
    end
  end

  def create_the_first_account
    message(:first_account)
    input == COMMANDS[:accept] ? create : console
  end

  def main_menu
    loop do
      main_menu_message
      case input
      when COMMANDS[:show_cards] then show_cards
      when COMMANDS[:card_create] then create_card
      when COMMANDS[:card_destroy] then destroy_card
      when COMMANDS[:put_money] then put_money
      when COMMANDS[:withdraw_money] then withdraw_money
      when COMMANDS[:send_money] then send_money
      when COMMANDS[:delete_account] then destroy_account
      when COMMANDS[:exit] then console
      else message(:wrong_command)
      end
    end
  end

  def destroy_account
    message(:destroy_account)
    return if input != COMMANDS[:accept]
    @account.destroy
    exit
  end

  def show_cards
    return message(:active_cards) if @account.cards.empty?

    @account.cards.each { |card| output(I18n.t('show_cards', number: card.number, type: card.type)) }
  end

  def create_card
    message(:could_create_one)
    type = input
    return if type == COMMANDS[:exit]
    return  message(:wrong_card_type) unless BaseCard.find_type(type)

    @account.create_card(type)
    update_db(@account)
  end

  def destroy_card
    output(I18n.t('common_phrases.if_you_want_to_delete'))
    show_cards_with_index
    output(I18n.t('common_phrases.press_exit'))
    select = input
    return if select == COMMANDS[:exit]

    return output(I18n.t('error_phrases.no_active_cards')) if @account.cards.count.zero?

    selected_card = @account.select_card(select)
    return output(I18n.t('error_phrases.wrong_number')) unless selected_card

    output(I18n.t('common_phrases.destroy_card', card: selected_card.number))
    return if input != COMMANDS[:accept]

    @account.cards.delete(selected_card)
    update_db(@account)
  end

  def put_money
    operation = prepare_money_operation(COMMANDS[:put_money])
    return unless operation

    card = operation[:chosen_card]
    amount = operation[:amount]
    return output(I18n.t('error_phrases.tax_higher')) unless card.operation_put_valid?(amount)

    card.put_money(amount)
    output(I18n.t('common_phrases.after_put', amount: amount, number: card.number,
                                              balance: card.balance, tax: card.put_tax(amount)))
    update_db(@account)
  end

  def withdraw_money
    operation = prepare_money_operation(COMMANDS[:withdraw_money])
    return unless operation

    card = operation[:chosen_card]
    amount = operation[:amount]
    return output(I18n.t('error_phrases.no_money_left')) unless card.operation_withdraw_valid?(amount)

    card.withdraw_money(amount)
    output(I18n.t('common_phrases.after_withdraw', amount: amount, number: card.number,
                                                   balance: card.balance, tax: card.withdraw_tax(amount)))
    update_db(@account)
  end

  def send_money
    operation = prepare_money_operation(COMMANDS[:send_money])
    return unless operation

    sender_card = operation[:chosen_card]
    amount = operation[:amount]
    output(I18n.t('common_phrases.recipient_card'))
    recipient_card = validate_recipiet_card
    return unless recipient_card
    return unless validate_send_operation_taxes(sender_card, recipient_card, amount)

    send_money_operation(sender_card, recipient_card, amount)
  end

   def cards
     @account.cards
   end

  private

  def send_money_operation(sender_card, recipient_card, amount)
    sender_card.send_money(amount)
    recipient_card.put_money(amount)
    output(I18n.t('common_phrases.after_withdraw', amount: amount, number: sender_card.number,
                                                   balance: sender_card.balance, tax: sender_card.sender_tax(amount)))
    output(I18n.t('common_phrases.after_put', amount: amount, number: recipient_card.number,
                                              balance: recipient_card.balance, tax: recipient_card.put_tax(amount)))
    accounts = load_db
    accounts.each do |account|
      update_db(account) if account.cards.map do |card|
        card.balance = sender_card.balance if card.number == sender_card.number
      end
      update_db(account) if account.cards.map do |card|
        card.balance = recipient_card.balance if card.number == recipient_card.number
      end
    end
  end

  def validate_recipiet_card
    input_number = input
    return output(I18n.t('error_phrases.invalid_number')) if input_number.size != BaseCard::CARD_NUMBER_SIZE

    accounts = load_db
    all_cards = accounts.map(&:cards).flatten
    finded_card = all_cards.detect { |card| card.number == input_number }
    finded_card || output(I18n.t('error_phrases.not_exist_card_number', number: input_number))
  end

  def validate_send_operation_taxes(sender_card, recipient_card, amount)
    return output(I18n.t('error_phrases.no_money_left')) unless sender_card.operation_send_valid?(amount)
    return output(I18n.t('error_phrases.no_money_on_recipient')) unless recipient_card.operation_put_valid?(amount)

    true
  end

  def prepare_money_operation(operation)
    action = COMMANDS.key(operation)
    output(I18n.t("operations.choose_card.#{action}"))
    show_cards_with_index
    select = input
    return if select == COMMANDS[:exit]

    selected_card = @account.select_card(select)
    return output(I18n.t('error_phrases.wrong_number')) unless selected_card

    output(I18n.t("operations.amount.#{action}"))
    amount = input.to_i
    amount.positive? ? amount : output(I18n.t('error_phrases.correct_amount'))
    return unless amount

    { chosen_card: selected_card, amount: amount }
  end

  def show_cards_with_index
    @account.cards.each_with_index do |card, index|
      output(I18n.t('common_phrases.show_cards_for_destroying', number: card.number,
                                                                type: card.type, index: index + 1))
    end
  end

  def name_input
    message(:put_name)
    input
  end

  def age_input
    message(:put_age)
    input.to_i
  end

  def login_input
    message(:put_login)
    input
  end

  def password_input
    message(:put_passw)
    input
  end

  def message(msg, params = {})
    output(I18n.t(msg, params))
  end

  def main_menu_message
    message(:main_menu_message_welcome, name: @account.name)
    message(:main_menu_message)
  end
end
