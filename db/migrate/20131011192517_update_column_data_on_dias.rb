class UpdateColumnDataOnDias < ActiveRecord::Migration
  def up
    Dia.all.each do |a|
        a.data = Date.new(a.mes.ano, a.mes.numero, a.numero)
        a.save
    end
  end

  def down
    Dia.all.each do |a|
      a.data = nil
      a.save
    end
  end
end
