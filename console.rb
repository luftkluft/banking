class Console
  include InOut
  include Uploader
  attr_accessor :current_account, :account
  def initialize(account)
    @account = account
  end

  def console
    output(I18n.t('hello_message'))
    a = gets.chomp
    if a == 'create'
      create
    elsif a == 'load'
      load
    else
      exit
    end
  end


  def create
    loop do
      name_input
      age_input
      login_input
      password_input
      break unless @account.errors.length != 0
      @account.errors.each do |e|
        puts e
      end
      @account.errors = []
    end
    @account.card = []
    new_accounts = accounts << @account
#    @current_account = @account
    File.open(@account.file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
  end

  def main_menu
    loop do
      output(I18n.t('main_menu_message_welcome', name: "#{@current_account.name}"))
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

      command = input

      if command == 'SC' || command == 'CC' || command == 'DC' || command == 'PM' || command == 'WM' || command == 'SM' || command == 'DA' || command == 'exit'
        if command == 'SC'
          show_cards
        elsif command == 'CC'
          create_card
        elsif command == 'DC'
          destroy_card
        elsif command == 'PM'
          put_money
        elsif command == 'WM'
          withdraw_money
        elsif command == 'SM'
          send_money
        elsif command == 'DA'
          destroy_account
          exit
        elsif command == 'exit'
          exit
          break
        end
      else
        output(I18n.t('error_phrases.wrong_command'))
      end
    end
  end

  def name_input
    output(I18n.t('ask_phrases.name'))
    @name = input
    unless @name != '' && @name[0].upcase == @name[0]
      @account.errors.push(I18n.t('account_validation_phrases.name.first_letter'))
    end
    @account.name = @name
  end

  def login_input
    output(I18n.t('ask_phrases.login'))
    login = input
    if login == ''
      @account.errors.push(I18n.t('account_validation_phrases.login.present'))
    end

    if login.length < 4
      @account.errors.push(I18n.t('account_validation_phrases.login.longer'))
    end

    if login.length > 20
      @account.errors.push(I18n.t('account_validation_phrases.login.shorter'))
    end

    if accounts.map { |a| a.login }.include? login
      @account.errors.push(I18n.t('account_validation_phrases.login.exists'))
    end

    @account.login = login
  end

  def password_input
    output(I18n.t('ask_phrases.password'))
    password = input
    if password == ''
      @account.errors.push(I18n.t('account_validation_phrases.password.present'))
    end

    if password.length < 6
      @account.errors.push(I18n.t('account_validation_phrases.password.longer'))
    end

    if password.length > 30
      @account.errors.push(I18n.t('account_validation_phrases.password.shorter'))
    end

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

  def create_the_first_account
    output(I18n.t('common_phrases.create_first_account'))
    if input == 'y'
      return create
    else
      return console
    end
  end

  def load
    loop do
      if !accounts.any?
        return create_the_first_account
      end

      output(I18n.t('ask_phrases.login'))
      login = input
      output(I18n.t('ask_phrases.password'))
      password = input

      if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
        a = accounts.select { |a| login == a.login }.first
        @current_account = a
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
    a = input
    if a == 'y'
      new_accounts = []
      accounts.each do |ac|
        if ac.login == @current_account.login
        else
          new_accounts.push(ac)
        end
      end
      File.open(@account.file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    end
  end
end