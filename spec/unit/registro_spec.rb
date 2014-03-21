require_relative '../spec_helper'

describe Registro do
  it "obtem uma modificação de criação correta" do
    @registro.atividade_mudanças_em_modificação({"observacao"=>[nil, "uma observação"]})
    @registro.save!
    @registro.modificacao.should == " adicionou uma observação"
  end

  it "obtem uma modificação de atualização correta" do
    @registro.atividade_mudanças_em_modificação({"duracao"=>[3600, 7200]})
    @registro.save!
    @registro.modificacao.should == " atualizou a duração de 01:00 para 02:00"
  end

  it "obtem modificação de criações correta" do
    @registro.atividade_mudanças_em_modificação({"observacao"=>[nil, "uma observação"], "cartao_id" =>[nil, 500]})
    @registro.save!
    @registro.modificacao.should == " adicionou uma observação, adicionou um cartão"
  end

  it "obtem modificação de atualizações correta" do
    @registro.atividade_mudanças_em_modificação({"duracao"=>[3600, 7200], "cartao_id" =>[350, 500]})
    @registro.save!
    @registro.modificacao.should == " atualizou a duração de 01:00 para 02:00, alterou o cartão"
  end

  before(:all) do
    @registro = FactoryGirl.create :registro
    @usuario  = FactoryGirl.create :desenvolvedor
  end
end
