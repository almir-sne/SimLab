# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :atividade do
    projeto_id 1
    horas 1.5
    user_id 1
    observacao "MyText"
    mes_id 1
    dia_id 1
  end
end
