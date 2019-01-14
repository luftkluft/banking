require 'yaml'

class Account
  include InOut
  include Uploader
  attr_accessor :login, :name, :age, :cards, :password, :file_path, :errors, :current_account

  def initialize
    @errors = []
    @cards = []
    @file_path = 'database/accounts.yml'
    @current_account = self
  end

  def create_card
    loop do
      output(I18n.t('could_create_one'))
      type = input
      if type == 'usual' || type == 'capitalist' || type == 'virtual'
        card = { type: 'usual', number: 16.times.map { rand(10) }.join, balance: 50.00 } if type == 'usual'
        card = { type: 'capitalist', number: 16.times.map { rand(10) }.join, balance: 100.00 } if type == 'capitalist'
        card = { type: 'virtual', number: 16.times.map { rand(10) }.join, balance: 150.00 } if type == 'virtual'
        save_card_to_base(card)
        break
      else
        output(I18n.t('error_phrases.wrong_card_type'))
      end
    end
  end

  def save_card_to_base(card)
    cards = @current_account.cards << card
    @current_account.cards = cards # important!!!
    new_accounts = []
    accounts.each do |account|
      if account.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(account)
      end
    end
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end

  def destroy_card
    loop do
      if @current_account.cards.any?
        output(I18n.t('common_phrases.if_you_want_to_delete'))
        @current_account.cards.each_with_index do |card, index|
          output(I18n.t('common_phrases.show_cards_for', number: (card[:number]).to_s,
                                                         type: (card[:type]).to_s,
                                                         index: (index + 1).to_s))
        end
        output(I18n.t('common_phrases.press_exit'))
        first_answer = input
        break if first_answer == COMMANDS[:exit]

        if first_answer&.to_i.to_i <= @current_account.cards.length && first_answer&.to_i.to_i > 0
          output(I18n.t('common_phrases.destroy_card',
                        card: (@current_account.cards[first_answer&.to_i.to_i - 1][:number]).to_s))
          second_answer = input
          if second_answer == COMMANDS[:accept]
            @current_account.cards.delete_at(first_answer&.to_i.to_i - 1)
            remove_card_from_base
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

  def remove_card_from_base
    new_accounts = []
    accounts.each do |account|
      if account.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(account)
      end
    end
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } # Storing
  end

  def show_cards
    if @current_account.cards.any?
      @current_account.cards.each do |card|
        output(I18n.t('common_phrases.show_cards', number: (card[:number]).to_s, type: (card[:type]).to_s))
      end
    else
      output(I18n.t('error_phrases.zero_cards'))
    end
  end

  def withdraw_money
    puts 'Choose the card for withdrawing:'
    answer, second_answer, third_answer = nil # answers for gets.chomp
    if @current_account.cards.any?
      @current_account.cards.each_with_index do |card, index|
        output(I18n.t('common_phrases.show_cards_for', number: (card[:number]).to_s,
                                                       type: (card[:type]).to_s,
                                                       index: (index + 1).to_s))
      end
      output(I18n.t('common_phrases.press_exit'))
      loop do
        answer = input
        break if answer == COMMANDS[:exit]

        if answer&.to_i.to_i <= @current_account.cards.length && answer&.to_i.to_i > 0
          current_card = @current_account.cards[answer&.to_i.to_i - 1]
          loop do
            output(I18n.t('operations.amount.withdraw_money'))
            second_answer = input
            if second_answer&.to_i.to_i > 0
              money_left = current_card[:balance] - second_answer&.to_i.to_i - withdraw_tax(current_card[:type],
                                                                                            current_card[:balance],
                                                                                            current_card[:number],
                                                                                            second_answer&.to_i.to_i)
              if money_left > 0
                current_card[:balance] = money_left
                @current_account.cards[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |account|
                  if account.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(account)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } # Storing
                puts "Money #{second_answer&.to_i.to_i} withdrawed from #{current_card[:number]}$.
                 Money left: #{current_card[:balance]}$.
                  Tax: #{withdraw_tax(current_card[:type],
                                      current_card[:balance],
                                      current_card[:number],
                                      second_answer&.to_i.to_i)}$"
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

    if @current_account.cards.any?
      @current_account.cards.each_with_index do |card, index|
        output(I18n.t('common_phrases.show_cards_for', number: (card[:number]).to_s,
                                                       type: (card[:type]).to_s,
                                                       index: (index + 1).to_s))
      end
      output(I18n.t('common_phrases.press_exit'))
      loop do
        answer = input
        break if answer == COMMANDS[:exit]

        if answer&.to_i.to_i <= @current_account.cards.length && answer&.to_i.to_i > 0
          current_card = @current_account.cards[answer&.to_i.to_i - 1]
          loop do
            output(I18n.t('operations.amount.put_money'))
            second_answer = input
            if second_answer&.to_i.to_i > 0
              if put_tax(current_card[:type],
                         current_card[:balance],
                         current_card[:number],
                         second_answer&.to_i.to_i) >= second_answer&.to_i.to_i
                output(I18n.t('error_phrases.tax_higher'))
                return
              else
                new_money_amount = current_card[:balance] + second_answer&.to_i.to_i - put_tax(current_card[:type],
                                                                                               current_card[:balance],
                                                                                               current_card[:number],
                                                                                               second_answer&.to_i.to_i)
                current_card[:balance] = new_money_amount
                @current_account.cards[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                accounts.each do |account|
                  if account.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(account)
                  end
                end
                File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } # Storing
                puts "Money #{second_answer&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type],
                                                                                                                                                current_card[:balance],
                                                                                                                                                current_card[:number],
                                                                                                                                                second_answer&.to_i.to_i)}"
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
    if @current_account.cards.any?
      @current_account.cards.each_with_index do |card, index|
        output(I18n.t('common_phrases.show_cards_for', number: (card[:number]).to_s,
                                                       type: (card[:type]).to_s,
                                                       index: (index + 1).to_s))
      end
      output(I18n.t('common_phrases.press_exit'))
      answer = input
      exit if answer == COMMANDS[:exit]
      if answer&.to_i.to_i <= @current_account.cards.length && answer&.to_i.to_i > 0
        sender_card = @current_account.cards[answer&.to_i.to_i - 1]
      else
        output(I18n.t('error_phrases.hoose_correct_card'))
        return
      end
    else
      output(I18n.t('error_phrases.zero_cards'))
      return
    end
    output(I18n.t('common_phrases.recipient_card'))
    second_answer = input
    if second_answer.length > 15 && second_answer.length < 17
      all_cards = accounts.map(&:cards).flatten
      if all_cards.select { |card| card[:number] == second_answer }.any?
        recipient_card = all_cards.select { |card| card[:number] == second_answer }.first
      else
        output(I18n.t('error_phrases.not_exist_card_number', number: second_answer.to_s))
        return
      end
    else
      output(I18n.t('error_phrases.invalid_number'))
      return
    end

    loop do
      output(I18n.t('operations.amount.withdraw_money'))
      third_answer = input
      if third_answer&.to_i.to_i > 0
        sender_balance = sender_card[:balance] - third_answer&.to_i.to_i - sender_tax(sender_card[:type],
                                                                                      sender_card[:balance], sender_card[:number],
                                                                                      third_answer&.to_i.to_i)
        recipient_balance = recipient_card[:balance] + third_answer&.to_i.to_i - put_tax(recipient_card[:type],
                                                                                         recipient_card[:balance], recipient_card[:number],
                                                                                         third_answer&.to_i.to_i)

        if sender_balance < 0
          output(I18n.t('error_phrases.no_money_left'))
        elsif put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], third_answer&.to_i.to_i) >= third_answer&.to_i.to_i
          output(I18n.t('error_phrases.no_money_send'))
        else
          sender_card[:balance] = sender_balance
          @current_account.cards[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          accounts.each do |account|
            if account.login == @current_account.login
              new_accounts.push(@current_account)
            elsif account.cards.map { |card| card[:number] }.include? second_answer
              recipient = account
              new_recipient_cards = []
              recipient.cards.each do |card|
                card[:balance] = recipient_balance if card[:number] == second_answer
                new_recipient_cards.push(card)
              end
              recipient.cards = new_recipient_cards
              new_accounts.push(recipient)
            end
          end
          File.open('accounts.yml', 'w') { |f| f.write new_accounts.to_yaml } # Storing
          puts "Money #{third_answer&.to_i.to_i}$ was put on #{sender_card[:number]}.
           Balance: #{recipient_balance}.
            Tax: #{put_tax(sender_card[:type],
                           sender_card[:balance],
                           sender_card[:number],
                           third_answer&.to_i.to_i)}$\n"
          puts "Money #{third_answer&.to_i.to_i}$ was put on #{second_answer}.
           Balance: #{sender_balance}.
            Tax: #{sender_tax(sender_card[:type],
                              sender_card[:balance],
                              sender_card[:number],
                              third_answer&.to_i.to_i)}$\n"
          break
        end
      else
        output(I18n.t('error_phrases.wrong_number'))
      end
    end
  end

  private

  def withdraw_tax(type, _balance, _number, amount)
    case type
    when 'usual'
      return amount * 0.05
    when 'capitalist'
      return amount * 0.04
    when 'virtual'
      return amount * 0.12
    end
    0
  end

  def put_tax(type, _balance, _number, amount)
    case type
    when 'usual'
      return amount * 0.02
    when 'capitalist'
      return 10
    when 'virtual'
      return 1
    end
    0
  end

  def sender_tax(type, _balance, _number, amount)
    case type
    when 'usual'
      return 20
    when 'capitalist'
      return amount * 0.1
    when 'virtual'
      return 1
    end
    0
  end
end
