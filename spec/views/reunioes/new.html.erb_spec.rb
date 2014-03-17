require 'spec_helper'

describe "reunioes/new" do
  before(:each) do
    assign(:reuniao, stub_model(Reuniao,
      :projeto_id => 1,
      :criador_id => 1,
      :concluida => false
    ).as_new_record)
  end

  it "renders new reuniao form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", reunioes_path, "post" do
      assert_select "input#reuniao_projeto_id[name=?]", "reuniao[projeto_id]"
      assert_select "input#reuniao_criador_id[name=?]", "reuniao[criador_id]"
      assert_select "input#reuniao_concluida[name=?]", "reuniao[concluida]"
    end
  end
end
