FactoryGirl.define do
  factory :projeto do
    nome "SemGoteraNaFau"
    data_de_inicio Date.new(2001,1,1)
    descricao "projeto que tenta fazer a FAU nao ter mais nenhum vazamento em seu telhado"
    valor 1000
    horas_totais 500
  end
end
