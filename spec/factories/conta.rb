# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contum, :class => 'Conta' do
    agencia "MyString"
    banco "MyString"
    numero "MyString"
    usuario_id 1
  end
end
