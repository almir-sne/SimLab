class UpdateColumnDataOnDias < ActiveRecord::Migration
  def up
    Dia.all.each do |d|
        d.data = Date.new(d.mes.ano, d.mes.numero, d.numero)
        d.save
    end
  end

  def down
    Dia.all.each do |d|
      d.data = nil
      d.save
    end
  end
end
