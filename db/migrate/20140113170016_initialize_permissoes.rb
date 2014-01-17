class InitializePermissoes < ActiveRecord::Migration
  def change
    Permissao.new(:nome => "admin").save
    Permissao.new(:nome => "coordenador").save
    Permissao.new(:nome => "normal").save
  end
end
