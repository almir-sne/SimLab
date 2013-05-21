# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :address do
    state "MyString"
    city "MyString"
    bairro "MyString"
    street "MyString"
    number 1
    cep "MyString"
    complemento "MyString"
    usuario_id 1
  end
end
