class Account
  include Store
  attr_accessor :login, :age, :name, :cards, :password, :errors
  MIN_LOGIN = 4
  MAX_LOGIN = 20
  MIN_PASSWORD = 6
  MAX_PASSWORD = 30
  MIN_AGE = 23
  MAX_AGE = 90
  
  def initialize(name, age, login, password)
    @name = name
    @age = age
    @login = login
    @password = password
    @cards = []
  end

  def validate
    @errors = []
    validate_name
    validate_age
    validate_login
    validate_password
  end

  def valid?
    @errors.empty?
  end

  private

  def validate_name
    @errors << Message.capitalize_error if @name.empty? || @name.capitalize != name
  end

  def validate_login
    @errors << Message.login_empty if @login.empty?
    @errors << Message.login_long_min(MIN_LOGIN) if @login.length < MIN_LOGIN
    @errors << Message.login_long_max(MAX_LOGIN) if @login.length > MAX_LOGIN
    @errors << Message.login_exist if accounts.map(&:login).include?(login)
  end

  def validate_password
    @errors << Message.password_empty if @password.empty?
    @errors << Message.password_long_min(MIN_PASSWORD) if @password.length < MIN_PASSWORD
    @errors << Message.password_long_max(MAX_PASSWORD) if @password.length > MAX_PASSWORD
  end

  def validate_age
    if @age.to_i.is_a?(Integer) && @age.to_i.between?(MIN_AGE, MAX_AGE)
      @age = age.to_i
    else
      @errors << Message.age_between(MIN_AGE, MAX_AGE)
    end
  end
end
