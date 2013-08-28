class RemoveColumnCelFromUsuario < ActiveRecord::Migration
  def up
    Usuario.all.each do |u|
      unless u.cel.blank?
        Telefone.new(:ddd => (u.cel.to 1), :numero => (u.cel.from 2), :usuario_id => u.id).save
      end
    end
    remove_column :usuarios, :cel
  end

  def down
    add_column :usuarios, :cel, :string
    Usuario.all.each do |u|
      t = u.telefones.last
      unless t.blank?
        u.cel = t.ddd + t.numero
        u.save
        t.destroy
      end
    end
  end
end
