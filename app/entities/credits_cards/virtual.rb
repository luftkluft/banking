module CreditCards
  class Virtual < Base
    attr_reader :data_card

    def initialize
      @data_card = {
        type: 'virtual',
        balance: 150.0,
        number: generate_card_number
      }
    end

    def withdraw_persent
      12
    end

    def put_fixed_tax
      1
    end

    def sender_fixed_tax
      1
    end
  end
end
