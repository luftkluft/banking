require 'yaml'
require 'pry'

class Account
  include InOut
  include Uploader
  attr_accessor :login, :name, :age, :card, :password, :file_path, :errors, :current_account

  def initialize
    @errors = []
    @card = []
    @file_path = 'database/accounts.yml'
    @current_account = self
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
        answer = input
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

  private

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
