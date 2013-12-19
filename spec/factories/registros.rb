# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :registro do
    modificacao "MyText"
    autor_id 1
    atividade_id 1
  end
end
