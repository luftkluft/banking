class Console
  include Store
  attr_accessor :current_account, :account
  OPTION = { create: 'create', load: 'load' }.freeze
  OPTION_CARDS = %w[usual capitalist virtual].freeze
  COMMANDS = {
    sc: 'SC',
    cc: 'CC',
    dc: 'DC',
    da: 'DA',
    exit: 'exit'
  }.freeze
  EXIT = 'exit'.freeze
  YES = 'y'.freeze

  def console
    Message.hello
    case user_input
    when OPTION[:create] then create
    when OPTION[:load] then load
    else exit
    end
  end

  def create
    loop do
      @account = Account.new(name_input, age_input, login_input, password_input)
      account.validate
      break if account.valid?
      account.errors.each { |error| puts error }
    end
    write_to_file(accounts << account)
    @current_account = account
    main_menu
  end

  def load
    loop do
      return create_the_first_account unless accounts.any?

      login = login_input
      password = password_input
      break if check_account(login, password)

      Message.load_error
    end
    main_menu
  end

  def create_the_first_account
    Message.create_first_account
    user_input == YES ? create : console
  end

  def main_menu
    loop do
      Message.main_menu(@current_account.name)
      case user_input
      when COMMANDS[:sc] then show_cards
      when COMMANDS[:cc] then create_card
      when COMMANDS[:dc] then destroy_card
      when COMMANDS[:da] then destroy_account && (return exit)
      when COMMANDS[:exit] then return exit
      else
        Message.wrong_command
      end
    end
  end

  def create_card
    loop do
      Message.create_card_message
      return Message.create_error unless OPTION_CARDS.include? card_option = user_input
      CreditCard.new(@current_account, card_option)
      break
    end
  end

  def destroy_card
    loop do
      if @current_account.cards.any?
        Message.want_delete_card
        display_cards_destroy
        Message.exit
        answer = user_input
        validate_cards(answer)
        break if answer == EXIT
      else
        Message.no_active_cards
        break
      end
    end
  end

  def show_cards
    return Message.no_card unless @current_account.cards.any?

    @current_account.cards.each do |card|
      Message.display_cards(card[:number], card[:type])
    end
  end

  def destroy_account
    Message.destroy_account
    return destroy_account_in_file(current_account) if user_input == YES
  end

  private

  def check_account(login, password)
    accounts.map { |account| { login: account.login, password: account.password } }.include?(login: login, password: password)
    @current_account = accounts.select { |account| login == account.login }.first
  end

  def user_input
    gets.chomp
  end

  def name_input
    Message.enter_name
    user_input
  end

  def age_input
    Message.enter_age
    user_input.to_i
  end

  def login_input
    Message.enter_login
    user_input
  end

  def password_input
    Message.enter_password
    user_input
  end

  def validate_cards(answer)
    return Message.wrong_number unless answer&.to_i <= @current_account.cards.length && answer&.to_i > 0
    Message.answer_destroy_card_show_number(@current_account.cards[answer.to_i - 1][:number])
    choose_card_destroy(answer)
  end

  def choose_card_destroy(answer)
    CreditCard.new(@current_account).destroy_card(answer.to_i - 1) if user_input == YES
  end

  def display_cards_destroy
    @current_account.cards.each_with_index { |card, index| Message.display_card_destroy(card[:number], card[:type], index + 1) }
  end
end

