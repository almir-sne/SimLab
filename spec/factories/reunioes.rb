# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reuniao do
    projeto_id 1
    criador_id 1
    inicio "2014-03-12 15:22:15"
    concluida false
  end
end
