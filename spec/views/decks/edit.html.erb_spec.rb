require_relative '../../spec_helper'

describe "decks/edit" do
  before(:each) do
    @deck = assign(:deck, stub_model(Deck,
      :nome => "MyString"
    ))
  end

  it "renders the edit deck form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", deck_path(@deck), "post" do
      assert_select "input#deck_nome[name=?]", "deck[nome]"
    end
  end
end
