require_relative '../spec_helper'

describe Ausencia do

	describe "relationships" do
		it { should have_one(:usuario).through(:dia) }
		it { should belong_to(:dia) }
		it { should belong_to(:projeto)}
		it { should belong_to(:mes) }
		it { should belong_to(:avaliador).class_name("Usuario")}
		it { should have_one(:anexo).dependent(:destroy)}
	end

#	describe "The horas method for Ausencia" do
#		context "initialized without time" do
#			let(:ausencia) {Ausencia.new}
#
#			# Necessita ter um usuário inicializado
#			it "has no time" do
#				ausencia.horas.should be nil
#			end
#
#		end
#	end
end
