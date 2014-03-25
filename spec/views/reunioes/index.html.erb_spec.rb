require 'spec_helper'

describe "reunioes/index" do
  before(:each) do
    assign(:reunioes, [
      stub_model(Reuniao,
        :projeto_id => 1,
        :criador_id => 2,
        :concluida => false
      ),
      stub_model(Reuniao,
        :projeto_id => 1,
        :criador_id => 2,
        :concluida => false
      )
    ])
  end

  it "renders a list of reunioes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
