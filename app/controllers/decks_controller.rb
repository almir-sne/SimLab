class DecksController < ApplicationController
  # GET /decks
  # GET /decks.json
  def index
    @decks = Deck.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end

  # GET /decks/1
  # GET /decks/1.json
  def show
    @deck = Deck.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deck }
    end
  end

  # GET /decks/new
  # GET /decks/new.json
  def new
    @deck = Deck.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deck }
    end
  end

  # GET /decks/1/edit
  def edit
    @deck = Deck.find(params[:id])
  end

  # POST /decks
  # POST /decks.json
  def create
    @deck = Deck.new
    respond_to do |format|
      if update_deck(@deck, deck_params)
        format.html { redirect_to decks_path, notice: 'Deck criado com sucesso.' }
        format.json { render json: @deck, status: :created, location: @deck }
      else
        format.html { render action: "new" }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /decks/1
  # PUT /decks/1.json
  def update
    @deck = Deck.find(params[:id])
    respond_to do |format|
      if update_deck(@deck, deck_params)
        format.html { redirect_to decks_path, notice: 'Deck atualizado com sucesso.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /decks/1
  # DELETE /decks/1.json
  def destroy
    @deck = Deck.find(params[:id])
    @deck.destroy

    respond_to do |format|
      format.html { redirect_to decks_url }
      format.json { head :no_content }
    end
  end

  def update_deck(deck, dparams)
    success = deck.update_attribute(:nome, dparams[:nome])

    dparams[:planning_cards_attributes].each do |key, attributes|
      card = PlanningCard.where(id: attributes[:id]).last
      if card.blank?
        card = PlanningCard.new
      end
      if attributes["_destroy"] == "1" and !card.blank?
        card.destroy()
      else
        card.deck = deck
        card.save
        success = success and card.update_attributes(nome: attributes[:nome], valor: attributes[:valor])
      end
    end
    success
  end

  def deck_params
    params.require(:deck).permit(:nome, planning_cards_attributes: [:id, :nome, :valor, :_destroy])
  end
end
