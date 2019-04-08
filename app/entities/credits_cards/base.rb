module CreditCards
  class Base
    CARD_NUMBER_SIZE = 16
    VALID_CARD_NUMBERS = 10
    def withdraw_tax(amount)
      amount / 100.0 * withdraw_persent + withdraw_fixed_tax
    end

    def put_tax(amount)
      amount / 100.0 * put_persent + put_fixed_tax
    end

    def sender_tax(amount)
      amount / 100.0 * sender_persent + sender_fixed_tax
    end

    def withdraw_fixed_tax
      0
    end

    def withdraw_persent
      0
    end

    def put_fixed_tax
      0
    end

    def put_persent
      0
    end

    def sender_fixed_tax
      0
    end

    def sender_persent
      0
    end

    private

    def generate_card_number
      Array.new(CARD_NUMBER_SIZE) { rand(VALID_CARD_NUMBERS) }.join
    end
  end
end
