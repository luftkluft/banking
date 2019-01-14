class Console
  include InOut
  include Uploader
  attr_accessor :current_account, :account
  def initialize(account)
    @account = account
  end

  def console
    output(I18n.t('hello_message'))
    case input
    when COMMANDS[:create] then create
    when COMMANDS[:load] then load
    else exit
    end
  end

  def create
    loop do
      name_input
      age_input
      login_input
      password_input
      break if @account.errors.empty?

      @account.errors.each do |error|
        puts error
      end
      @account.errors = []
    end
    save_account_to_base
  end

  def save_account_to_base
    @account.cards = []
    new_accounts = accounts << @account
    @current_account = @account
    File.open(@account.file_path, 'w') { |f| f.write new_accounts.to_yaml } # Storing
  end

  def main_menu
    loop do
      output(I18n.t('main_menu_message_welcome', name: @current_account.name.to_s))
      # output(I18n.t('common_phrases.create_first_account'))
      puts 'If you want to:'
      puts '- show all cards - press SC'
      puts '- create card - press CC'
      puts '- destroy card - press DC'
      puts '- put money on card - press PM'
      puts '- withdraw money on card - press WM'
      puts '- send money to another card  - press SM'
      puts '- destroy account - press `DA`'
      puts '- exit from account - press `exit`'

      case input
      when COMMANDS[:show_cards] then show_cards
      when COMMANDS[:card_create] then create_card
      when COMMANDS[:card_destroy] then destroy_card
      when COMMANDS[:put_money] then put_money
      when COMMANDS[:withdraw_money] then withdraw_money
      when COMMANDS[:send_money] then send_money
      when COMMANDS[:delete_account] then destroy_account
      when COMMANDS[:exit]
        exit
        break
      else output(I18n.t('error_phrases.wrong_command'))
      end
    end
  end

  def create_the_first_account
    output(I18n.t('common_phrases.create_first_account'))
    return create if input == COMMANDS[:accept]

    console
  end

  def load
    loop do
      return create_the_first_account if accounts.none?

      output(I18n.t('ask_phrases.login'))
      login = input
      output(I18n.t('ask_phrases.password'))
      password = input
      if accounts.map { |account| { login: account.login, password: account.password } }
                 .include?(login: login, password: password)
        account = accounts.select { |account| login == account.login }.first
        @current_account = account
        @account.current_account = @current_account
        break
      else
        output(I18n.t('error_phrases.user_not_exists'))
        next
      end
    end
    main_menu
  end

  def show_cards
    @account.show_cards
  end

  def create_card
    @account.create_card
  end

  def destroy_card
    @account.destroy_card
  end

  def withdraw_money
    @account.withdraw_money
  end

  def put_money
    @account.put_money
  end

  def send_money
    @account.send_money
  end

  def destroy_account
    output(I18n.t('common_phrases.destroy_account'))
    remove_account_from_base if input == COMMANDS[:accept]
    exit
  end

  private

  def login_input
    output(I18n.t('ask_phrases.login'))
    login = input
    @account.errors.push(I18n.t('account_validation_phrases.login.present')) if login == ''
    @account.errors.push(I18n.t('account_validation_phrases.login.longer')) if login.length < 4
    @account.errors.push(I18n.t('account_validation_phrases.login.shorter')) if login.length > 20
    @account.errors.push(I18n.t('account_validation_phrases.login.exists')) if accounts.map(&:login).include? login
    @account.login = login
  end

  def password_input
    output(I18n.t('ask_phrases.password'))
    password = input
    @account.errors.push(I18n.t('account_validation_phrases.password.present')) if password == ''
    @account.errors.push(I18n.t('account_validation_phrases.password.longer')) if password.length < 6
    @account.errors.push(I18n.t('account_validation_phrases.password.shorter')) if password.length > 30
    @account.password = password
  end

  def age_input
    output(I18n.t('ask_phrases.age'))
    age = input
    if age.to_i.is_a?(Integer) && age.to_i >= 23 && age.to_i <= 90
      age = age.to_i
    else
      @account.errors.push(I18n.t('account_validation_phrases.age.length'))
    end
    @account.age = age
  end

  def name_input
    output(I18n.t('ask_phrases.name'))
    @name = input
    if @name == '' || @name[0].upcase != @name[0]
      @account.errors.push(I18n.t('account_validation_phrases.name.first_letter'))
    end
    @account.name = @name
  end

  def remove_account_from_base
    new_accounts = []
    accounts.each do |account|
      if account.login == @current_account.login
      else
        new_accounts.push(account)
      end
    end
    File.open(@account.file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
