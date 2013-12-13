require 'spec_helper'

feature "Projetos" do
	include Helpers

	describe "novo" do
		scenario "deveria poder ser criado" do
			admin_faz_login
		  visit projetos_path
		  fill_in "Nome",  :with => "asdf"
		  fill_in "Descrição", :with => "asdfasd"
		  click_button "Salvar"
		  page.should have_content(I18n.t("projetos.create.success", :model => "Projeto"))
		  page.should have_content(@projeto_novo[:nome])
		end

		scenario "nao poderia ser criado por desenvolvedor" do
		  desenvolvedor_faz_login
		  visit projetos_path
		  fill_in "Nome",  :with => @projeto_novo[:nome]
		  fill_in "Descrição", :with => @projeto_novo[:descricao]
		  click_button "Salvar"
		  page.should have_content(I18n.t("unauthorized.manage.all") )
		end
	end

	describe "existente" do
		scenario "deveria poder ser editado" do
		  projeto = FactoryGirl.create(:projeto)
		  admin_faz_login
		  visit projetos_path
		  click_link projeto.nome
		  fill_in "Nome", :with => "Teste"
#     save_and_open_page
 		  click_button "Salvar"
		  page.should have_content(I18n.t("projetos.update.sucess"))
		end

		scenario "nao poderia ser editado por desenvolvedor" do
		  projeto = FactoryGirl.create(:projeto)
		  desenvolvedor_faz_login
		  visit projetos_path
		  click_link projeto.nome
 		  page.should have_content(I18n.t("unauthorized.manage.all") )
		end

		scenario "não deveria ser acessivel sem login" do
		  visit projetos_path
		  page.should have_content(I18n.t("devise.failure.unauthenticated"))
		end

	end

	before(:each) do
	  @projeto_novo = FactoryGirl.attributes_for(:projeto)
	end
end
