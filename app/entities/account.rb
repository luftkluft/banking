class Account
  attr_accessor :name, :password, :login, :age, :cards, :errors
  include Uploader
  VALID_RANGE = { age: (23..89), login: (4..20), password: (6..30) }.freeze
  def initialize
    @name = ''
    @age = 0
    @login = ''
    @password = ''
    @cards = []
    @errors = []
  end

  def valid?
    validate
    @errors.empty?
  end

  def destroy
    save_to_db(load_db.reject { |account| account.login == @login })
  end

  def create_card(type)
    case type
    when BaseCard::VALID_TYPES[:usual] then @cards << Usual.new(type)
    when BaseCard::VALID_TYPES[:capitalist] then @cards << Capitalist.new(type)
    when BaseCard::VALID_TYPES[:virtual] then @cards << Virtual.new(type)
    end
  end

  def find_card_by_index(choice)
    @cards[choice.to_i - 1]
  end

  def select_card(input)
    return unless (1..@cards.size).cover?(input.to_i)

    find_card_by_index(input)
  end

  private

  def validate
    validate_login
    validate_name
    validate_age
    validate_password
  end

  def validate_name
    @errors << I18n.t('account_validation_phrases.name.first_letter') unless first_letter_uppcase?
  end

  def validate_login
    @errors << I18n.t('account_validation_phrases.login.present') if @login.empty?
    @errors << I18n.t('account_validation_phrases.login.longer') if @login.size < VALID_RANGE[:login].min
    @errors << I18n.t('account_validation_phrases.login.shorter') if @login.size > VALID_RANGE[:login].max
    @errors << I18n.t('account_validation_phrases.login.exists') if account_exists?
  end

  def validate_password
    @errors << I18n.t('account_validation_phrases.password.present') if @password.empty?
    @errors << I18n.t('account_validation_phrases.password.longer') if @password.size < VALID_RANGE[:password].min
    @errors << I18n.t('account_validation_phrases.password.shorter') if @password.size > VALID_RANGE[:password].max
  end

  def validate_age
    @errors << I18n.t('account_validation_phrases.age.length') unless (VALID_RANGE[:age]).cover?(@age)
  end

  def first_letter_uppcase?
    @name.capitalize[0] == @name[0]
  end

  def account_exists?
    load_db.detect { |account_in_db| account_in_db.login == @login }
  end
end
