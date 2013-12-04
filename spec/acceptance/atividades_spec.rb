require 'spec_helper'

feature "Atividades" do
	include Helpers

	describe "novas" do
	  scenario "podem ser criadas por qualquer usuario" do
      usuario = desenvolvedor_faz_login
      visit new_dia_path(:data => "2013-12-04", :usuario_id => usuario.id)
      click_on "Novo horario"
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

end
