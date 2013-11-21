require 'spec_helper'

feature "Atividades" do
	include Helpers

	describe "novas" do
	  scenario "podem ser criadas por qualquer usuario" do
      desenvolvedor_faz_login
      click_link "Maio"
      save_and_open_page
      fill_in "dia_numero", :with => 30
      select "19", :from => "dia_entrada_4i"
      select "00", :from => "dia_entrada_5i"
      select "22", :from => "dia_saida_4i"
      select "00", :from => "dia_saida_5i"
      select "01", :from => "dia_intervalo_4i"
      select "00", :from => "dia_intervalo_5i"
      select "Projeto Teste", :from => "dia_atividades_attributes_0_projeto_id"
      select "01", :from => "dia_atividades_attributes_0_horas_4i"
      select "00", :from => "dia_atividades_attributes_0_horas_5i"
      fill_in "dia_atividades_attributes_0_observacao", :with => "Apenas uma observacao!"
      click_button "Ok"
      page.should have_content(I18n.t("atividades.create.sucess"))
	  end

#	  it "sobre novas" do
#	    desenvolvedor_faz_login
#	    click_link "Maio"
#	    click_on  "Incluir Atividade"
#	    save_and_open_page

#	  end
	end

  before(:each) do
	  FactoryGirl.create(:projeto)
	  FactoryGirl.create(:projeto_novo)
	end


end
