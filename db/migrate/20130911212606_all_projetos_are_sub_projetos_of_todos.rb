class AllProjetosAreSubProjetosOfTodos < ActiveRecord::Migration
  def up
    todos_os_projetos = Projeto.all
    todo = Projeto.new(
      :nome => "Todos",
      :descricao => "pai de todos os projetos orfãos",
      :data_de_inicio => Date.new(2000, 1, 1)
    )
    todo.save!
    todos_os_projetos.each{|projeto| projeto.update_attribute(:super_projeto_id, todo.id)}
  end

  def down
    Projeto.find_by_nome("Todo").destroy
  end
end
