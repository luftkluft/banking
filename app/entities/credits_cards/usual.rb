module CreditCards
  class Usual < Base
    attr_reader :data_card

    def initialize
      @data_card = {
        type: 'usual',
        balance: 50.0,
        number: generate_card_number
      }
    end

    def withdraw_persent
      5
    end

    def put_persent
      2
    end

    def sender_fixed_tax
      20
    end
  end
end
