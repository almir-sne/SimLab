# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ausencia do
    usuario_id 1
    mes_id 1
    justificativa "MyString"
    abonada false
    mensagem "MyString"
    avaliador_id 1
    duracao 1
    dia 1
  end
end
