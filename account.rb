require 'yaml'
require 'pry'

class Account
  include InOut
  attr_accessor :login, :name, :card, :password, :file_path

  def initialize
    @errors = []
    @file_path = 'database/accounts.yml'
  end

  def console
      output(I18n.t('hello_message'))
    # FIRST SCENARIO. IMPROVEMENT NEEDED

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
      break unless @errors.length != 0
      @errors.each do |e|
        puts e
      end
      @errors = []
    end

    @card = []
    new_accounts = accounts << self
    @current_account = self
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    main_menu
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
        break
      else
        output(I18n.t('error_phrases.user_not_exists'))
        next
      end
    end
    main_menu
  end

  def create_the_first_account
    output(I18n.t('common_phrases.create_first_account'))
    if input == 'y'
      return create
    else
      return console
    end
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

  def create_card
    loop do
      output(I18n.t('could_create_one'))

      ct = input
      if ct == 'usual' || ct == 'capitalist' || ct == 'virtual'
        if ct == 'usual'
          card = {
            type: 'usual',
            number: 16.times.map{rand(10)}.join,
            balance: 50.00
          }
        elsif ct == 'capitalist'
          card = {
            type: 'capitalist',
            number: 16.times.map{rand(10)}.join,
            balance: 100.00
          }
        elsif ct == 'virtual'
          card = {
            type: 'virtual',
            number: 16.times.map{rand(10)}.join,
            balance: 150.00
          }
        end
        cards = @current_account.card << card
        @current_account.card = cards #important!!!
        new_accounts = []
        accounts.each do |ac|
          if ac.login == @current_account.login
            new_accounts.push(@current_account)
          else
            new_accounts.push(ac)
          end
        end
        File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
        break
      else
        output(I18n.t('error_phrases.wrong_card_type'))
      end
    end
  end

  def destroy_card
    loop do
      if @current_account.card.any?
        output(I18n.t('common_phrases.if_you_want_to_delete'))
        @current_account.card.each_with_index do |c, i|
          output(I18n.t('common_phrases.show_cards_for', number: "#{c[:number]}",
                                                        type: "#{c[:type]}", 
                                                        index: "#{i + 1}"))

        end
        output(I18n.t('common_phrases.press_exit'))
        answer = input
        break if answer == 'exit'
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          output(I18n.t('common_phrases.destroy_card',
            card: "#{@current_account.card[answer&.to_i.to_i - 1][:number]}"))
          a2 = input
          if a2 == 'y'
            @current_account.card.delete_at(answer&.to_i.to_i - 1)
            new_accounts = []
            accounts.each do |ac|
              if ac.login == @current_account.login
                new_accounts.push(@current_account)
              else
                new_accounts.push(ac)
              end
            end
            File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
            break
          else
            return
          end
        else
          output(I18n.t('error_phrases.wrong_number'))
        end
      else
        output(I18n.t('error_phrases.zero_cards'))
        break
      end
    end
  end

  def show_cards
    if @current_account.card.any?
      @current_account.card.each do |c|
        output(I18n.t('common_phrases.show_cards', number: "#{c[:number]}", type: "#{c[:type]}"))
      end
    else
      output(I18n.t('error_phrases.zero_cards'))
    end
  end

  def withdraw_money
    puts 'Choose the card for withdrawing:'
    answer, a2, a3 = nil #answers for gets.chomp
    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        output(I18n.t('common_phrases.show_cards_for', number: "#{c[:number]}",
          type: "#{c[:type]}", 
          index: "#{i + 1}"))
      end
      output(I18n.t('common_phrases.press_exit'))
      loop do
        answer = input
        break if answer == 'exit'
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          current_card = @current_account.card[answer&.to_i.to_i - 1]
          loop do
            output(I18n.t('operations.amount.withdraw_money'))
            a2 = input
            if a2&.to_i.to_i > 0
              money_left = current_card[:balance] - a2&.to_i.to_i - withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
              if money_left > 0
                current_card[:balance] = money_left
                @current_account.card[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |ac|
                  if ac.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(ac)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
                puts "Money #{a2&.to_i.to_i} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}$"
                return
              else
                output(I18n.t('error_phrases.no_money_left'))
                return
              end
            else
              output(I18n.t('error_phrases.correct_amount'))
              return
            end
          end
        else
          output(I18n.t('error_phrases.wrong_number'))
          return
        end
      end
    else
      output(I18n.t('error_phrases.zero_cards'))
    end
  end

  def put_money
    puts 'Choose the card for putting:'

    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        output(I18n.t('common_phrases.show_cards_for', number: "#{c[:number]}",
          type: "#{c[:type]}", 
          index: "#{i + 1}"))
      end
      output(I18n.t('common_phrases.press_exit'))
      loop do
        answer = gets.chomp
        break if answer == 'exit'
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
          current_card = @current_account.card[answer&.to_i.to_i - 1]
          loop do
            output(I18n.t('operations.amount.put_money'))
            a2 = input
            if a2&.to_i.to_i > 0
              if put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i) >= a2&.to_i.to_i
                output(I18n.t('error_phrases.tax_higher'))
                return
              else
                new_money_amount = current_card[:balance] + a2&.to_i.to_i - put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
                current_card[:balance] = new_money_amount
                @current_account.card[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |ac|
                  if ac.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(ac)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
                puts "Money #{a2&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}"
                return
              end
            else
              output(I18n.t('error_phrases.correct_amount_mony'))
              return
            end
          end
        else
          output(I18n.t('error_phrases.wrong_number'))
          return
        end
      end
    else
      output(I18n.t('error_phrases.zero_cards'))
    end
  end

  def send_money
    output(I18n.t('operations.send_money'))
    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        output(I18n.t('common_phrases.show_cards_for', number: "#{c[:number]}",
          type: "#{c[:type]}", 
          index: "#{i + 1}"))
      end
      output(I18n.t('common_phrases.press_exit'))
      answer = input
      exit if answer == 'exit'
      if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i > 0
        sender_card = @current_account.card[answer&.to_i.to_i - 1]
      else
        output(I18n.t('error_phrases.hoose_correct_card'))
        return
      end
    else
      output(I18n.t('error_phrases.zero_cards'))
      return
    end
    output(I18n.t('common_phrases.recipient_card'))
    a2 = input
    if a2.length > 15 && a2.length < 17
      all_cards = accounts.map(&:card).flatten
      if all_cards.select { |card| card[:number] == a2 }.any?
        recipient_card = all_cards.select { |card| card[:number] == a2 }.first
      else
        output(I18n.t('error_phrases.not_exist_card_number', number: "#{a2}"))
        return
      end
    else
      output(I18n.t('error_phrases.invalid_number'))
      return
    end

    loop do
      output(I18n.t('operations.amount.withdraw_money'))
      a3 = input
      if a3&.to_i.to_i > 0
        sender_balance = sender_card[:balance] - a3&.to_i.to_i - sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)
        recipient_balance = recipient_card[:balance] + a3&.to_i.to_i - put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i)

        if sender_balance < 0
          output(I18n.t('error_phrases.no_money_left'))
        elsif put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i) >= a3&.to_i.to_i
          output(I18n.t('error_phrases.no_money_send'))
        else
          sender_card[:balance] = sender_balance
          @current_account.card[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          accounts.each do |ac|
            if ac.login == @current_account.login
              new_accounts.push(@current_account)
            elsif ac.card.map { |card| card[:number] }.include? a2
              recipient = ac
              new_recipient_cards = []
              recipient.card.each do |card|
                if card[:number] == a2
                  card[:balance] = recipient_balance
                end
                new_recipient_cards.push(card)
              end
              recipient.card = new_recipient_cards
              new_accounts.push(recipient)
            end
          end
          File.open('accounts.yml', 'w') { |f| f.write new_accounts.to_yaml } #Storing
          puts "Money #{a3&.to_i.to_i}$ was put on #{sender_card[:number]}. Balance: #{recipient_balance}. Tax: #{put_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
          puts "Money #{a3&.to_i.to_i}$ was put on #{a2}. Balance: #{sender_balance}. Tax: #{sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
          break
        end
      else
      output(I18n.t('error_phrases.wrong_number'))
      end
    end
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
      File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    end
  end

  private
  # output(I18n.t('ask_phrases.login'))
  # login = input
  # output(I18n.t('ask_phrases.password'))
  # password = input


  def name_input
    output(I18n.t('ask_phrases.name'))
    # puts 'Enter your name'
    @name = input
    unless @name != '' && @name[0].upcase == @name[0]
      @errors.push(I18n.t('account_validation_phrases.name.first_letter'))
    end
  end

  def login_input
    output(I18n.t('ask_phrases.login'))
    @login = input
    if @login == ''
      @errors.push(I18n.t('account_validation_phrases.login.present'))
    end

    if @login.length < 4
      @errors.push(I18n.t('account_validation_phrases.login.longer'))
    end

    if @login.length > 20
      @errors.push(I18n.t('account_validation_phrases.login.shorter'))
    end

    if accounts.map { |a| a.login }.include? @login
      @errors.push(I18n.t('account_validation_phrases.login.exists'))
    end
  end

  def password_input
    output(I18n.t('ask_phrases.password'))
    @password = input
    if @password == ''
      @errors.push(I18n.t('account_validation_phrases.password.present'))
    end

    if @password.length < 6
      @errors.push(I18n.t('account_validation_phrases.password.longer'))
    end

    if @password.length > 30
      @errors.push(I18n.t('account_validation_phrases.password.shorter'))
    end
  end

  def age_input
    output(I18n.t('ask_phrases.age'))
    @age = input
    if @age.to_i.is_a?(Integer) && @age.to_i >= 23 && @age.to_i <= 90
      @age = @age.to_i
    else
      @errors.push(I18n.t('account_validation_phrases.age.length'))
    end
  end

  def accounts
    if File.exists?('database/accounts.yml')
      YAML.load_file('database/accounts.yml')
    else
      []
    end
  end

  def withdraw_tax(type, balance, number, amount)
    if type == 'usual'
      return amount * 0.05
    elsif type == 'capitalist'
      return amount * 0.04
    elsif type == 'virtual'
      return amount * 0.88
    end
    0
  end

  def put_tax(type, balance, number, amount)
    if type == 'usual'
      return amount * 0.02
    elsif type == 'capitalist'
      return 10
    elsif type == 'virtual'
      return 1
    end
    0
  end

  def sender_tax(type, balance, number, amount)
    if type == 'usual'
      return 20
    elsif type == 'capitalist'
      return amount * 0.1
    elsif type == 'virtual'
      return 1
    end
    0
  end
end
