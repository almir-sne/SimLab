class AddColumnAtivoToWorkon < ActiveRecord::Migration
  def change
    add_column :workons, :ativo, :boolean
    Workon.all.each do |u|
      u.ativo = true
      u.save
    end
  end
end
