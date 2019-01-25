module CreditCards
  class Capitalist < Base
    attr_reader :data_card

    def initialize
      @data_card = {
        type: 'capitalist',
        balance: 100.0,
        number: generate_card_number
      }
    end

    def withdraw_persent
      4
    end

    def put_fixed_tax
      10
    end

    def sender_persent
      10
    end
  end
end
