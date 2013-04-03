# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dium, :class => 'Dia' do
    numero 1
    entrada "2013-04-01 17:38:40"
    saida "2013-04-01 17:38:40"
    intervalo 1.5
    usuario_id 1
    mes_id 1
  end
end
