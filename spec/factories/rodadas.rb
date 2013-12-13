# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rodada do
    cartao_id 1
    inicio "2013-12-13 14:39:22"
    fim "2013-12-13 14:39:22"
    deck_id 1
    criador_id 1
    finalizador_id 1
  end
end
