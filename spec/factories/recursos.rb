# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurso, :class => 'Recursos' do
    origem "MyString"
    mes_id 1
    valor 1.5
  end
end
