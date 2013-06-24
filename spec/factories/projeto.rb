FactoryGirl.define do
  factory :projeto, class: Projeto  do
    nome "Projeto Teste"
    data_de_inicio Date.new(2001,1,1)
    descricao "projeto que tenta fazer a FAU nao ter mais nenhum vazamento em seu telhado"
    valor 1000
    horas_totais 500
  end

   factory :projeto_novo, class: Projeto do
    nome "Projeto Teste 2"
    data_de_inicio Date.new(2008,2,3)
    descricao "projeto teste 2"
    valor 100
    horas_totais 5000
  end
end
