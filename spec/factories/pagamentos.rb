# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pagamento do
    mes_id 1
    usuario_id 1
    valor "9.99"
    data "2013-09-18"
    fonte "MyString"
    motivo "MyString"
  end
end
