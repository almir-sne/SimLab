class ChangeTableAtividades < ActiveRecord::Migration
  def up
    Atividade.all.each do |a|
      if !a[:cartao_id].blank?
        c = Cartao.find_or_create_by_trello_id(a[:cartao_id]) 
        c.save
        a[:cartao_id] = c.id.to_s
        a.save
      end
    end
  end

  def down
    Atividade.all.each do |a|
      if !a[:cartao_id].blank?
        c = Cartao.find(a[:cartao_id].to_i)     
        a[:cartao_id] = c.trello_id
        a.save
      end
    end
    Cartao.destroy_all
  end
end
