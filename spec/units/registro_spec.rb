require 'spec_helper'

describe Registro do
  it "obtem uma modificação de criação correta" do
    @registro.transforma_hash_em_modificacao({"observacao"=>[nil, "uma observação"]})
    @registro.save!
    @registro.modificacao.should == " adicionou uma observação"
  end

  it "obtem uma modificação de atualização correta" do
    @registro.transforma_hash_em_modificacao({"duracao"=>[3600, 7200]})
    @registro.save!
    @registro.modificacao.should == " atualizou a duração de 1hs para 2hs"
  end

  it "obtem modificação de criações correta" do
    @registro.transforma_hash_em_modificacao({"observacao"=>[nil, "uma observação"], "trello_id" =>[nil, 500]})
    @registro.save!
    @registro.modificacao.should == " adicionou uma observação, adicionou um cartão"
  end

  it "obtem modificação de atualizações correta" do
    @registro.transforma_hash_em_modificacao({"duracao"=>[3600, 7200], "trello_id" =>[350, 500]})
    @registro.save!
    @registro.modificacao.should == " atualizou a duração de 1hs para 2hs, alterou o cartão"
  end

  before(:all) do
    @registro = FactoryGirl.create :registro
    @usuario  = FactoryGirl.create :desenvolvedor
  end
end
