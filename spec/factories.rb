FactoryGirl.define do
  factory :projeto do
    name "SemGoteraNaFau"
    data_de_inicio DateTime.new(2001,1,1)
    descricao "projeto que tenta fazer a FAU nao ter mais nenhum vazamento em seu telhado"
    valor 1000
    horas_totais 500
  end
end
