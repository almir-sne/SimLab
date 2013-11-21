# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :estimativa do
    cartao_id 1
    usuario_id 1
    estimativa 1.5
    rodada 1
  end
end
