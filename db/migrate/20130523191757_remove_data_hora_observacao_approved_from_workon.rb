class RemoveDataHoraObservacaoApprovedFromWorkon < ActiveRecord::Migration
  def up
    remove_column :workons, :data
    remove_column :workons, :horas
    remove_column :workons, :observacao
    remove_column :workons, :approved
  end

  def down
    add_column :workons, :approved, :integer
    add_column :workons, :observacao, :text
    add_column :workons, :horas, :float
    add_column :workons, :data, :date
  end
end
