class AddDataToAtividade < ActiveRecord::Migration
  def up
    add_column :atividades, :data, :date
    Atividade.all.each do |a|
      begin
        unless a.dia.blank?
          a.data = a.dia.data
          a.save
        end
      rescue => ex
        nil
      end
    end
  end

  def down
    remove_column :atividades, :data
  end
end
