class Message
  class << self
    def display(message)
      puts message
    end

    def hello
      puts I18n.t(:hello)
    end

    def enter_login
      puts I18n.t(:enter_login)
    end

    def enter_login
      puts I18n.t(:enter_login)
    end

    def enter_password
      puts I18n.t(:enter_password)
    end

    def main_menu(name)
      puts I18n.t(:main_menu, name: name)
    end

    def wrong_command
      puts I18n.t(:wrong_command)
    end

    def create_card_message
      puts I18n.t(:create_card_message)
    end

    def no_card
      puts I18n.t(:no_card)
    end

    def display_cards(card_number, card_type)
      puts I18n.t(:display_cards, card_number: card_number, card_type: card_type)
    end

    def want_delete_card
      puts I18n.t('destroy_card.want_delete_card')
    end

    def display_card_destroy(number, type, number_card)
      puts I18n.t('destroy_card.display_card_destroy', number: number, type: type, number_card: number_card)
    end

    def answer_destroy_card_show_number(number)
      puts I18n.t('destroy_card.answer_destroy_card_show_number', number: number)
    end

    def wrong_number
      puts I18n.t('destroy_card.wrong_number')
    end

    def no_active_cards
      puts I18n.t('destroy_card.no_active_cards')
    end

    def exit
      puts I18n.t('destroy_card.exit')
    end

    def enter_name
      puts I18n.t(:enter_name)
    end

    def enter_age
      puts I18n.t(:enter_age)
    end

    def load_error
      puts I18n.t(:load_error)
    end

    def destroy_account
      puts I18n.t(:destroy_account)
    end

    def create_first_account
      puts I18n.t(:create_first_account)
    end

    def capitalize_error
      I18n.t('name_errors.capitalize_error')
    end

    def login_empty
      I18n.t('login_errors.login_empty')
    end

    def login_long_min(min)
      I18n.t('login_errors.login_long_min', min: min)
    end

    def login_long_max(max)
      I18n.t('login_errors.login_long_max', max: max)
    end

    def login_exist
      I18n.t('login_errors.login_exist')
    end

    def password_empty
      I18n.t('password_errors.password_empty')
    end

    def create_error
      I18n.t('create_card_error.create_error')
    end

    def password_long_min(min)
      I18n.t('password_errors.password_long_min', min: min)
    end

    def password_long_max(max)
      I18n.t('password_errors.password_long_max', max: max)
    end

    def age_between(min, max)
      I18n.t('age_errors.age_between', min: min, max: max)
    end
  end
end
