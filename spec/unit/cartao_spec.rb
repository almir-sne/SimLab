require_relative '../spec_helper'

describe Cartao do
	describe "relationships" do
		it { should have_many(:atividades) }		
		it { should have_many(:rodadas) }
		it { should have_many(:filhos).class_name("Cartao").with_foreign_key("pai_id").dependent(:nullify) }
		it { should have_and_belong_to_many(:tags) }
		it { should belong_to(:pai).class_name("Cartao")}
	end

	it { should accept_nested_attributes_for(:tags) }

end
