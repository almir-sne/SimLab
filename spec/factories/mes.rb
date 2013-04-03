# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :me, :class => 'Mes' do
    numero 1
    ano 1
    user_id 1
    valor_hora 1.5
    horas_contratadas 1
  end
end
