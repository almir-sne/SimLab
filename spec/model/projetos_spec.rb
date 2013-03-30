require 'spec_helper'

describe Projeto do
  describe "deveria ter attributos validos" do
    it { should validate_presence_of :nome }
    it { should validate_presence_of :descricao }
    it { should validate_numericality_of :valor }
    it { should validate_uniqueness_of :nome }
  end
end