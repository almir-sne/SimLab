require 'spec_helper'

describe "reunioes/edit" do
  before(:each) do
    @reuniao = assign(:reuniao, stub_model(Reuniao,
      :projeto_id => 1,
      :criador_id => 1,
      :concluida => false
    ))
  end

  it "renders the edit reuniao form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", reuniao_path(@reuniao), "post" do
      assert_select "input#reuniao_projeto_id[name=?]", "reuniao[projeto_id]"
      assert_select "input#reuniao_criador_id[name=?]", "reuniao[criador_id]"
      assert_select "input#reuniao_concluida[name=?]", "reuniao[concluida]"
    end
  end
end
