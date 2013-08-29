# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contrato do
    inicio "2013-08-28"
    fim "2013-08-28"
    valor_hora "9.99"
    hora_mes 1
    usuario_id 1
    tipo "MyString"
    contratante "MyString"
    funcao "MyString"
  end
end
