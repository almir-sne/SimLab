class WorkonsController < ApplicationController
  # GET /workons
  # GET /workons.json
  def index
    @workons = Workon.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workons }
    end
  end

  # GET /workons/1
  # GET /workons/1.json
  def show
    @workon = Workon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workon }
    end
  end

  # GET /workons/new
  # GET /workons/new.json
  def new
    @workon = Workon.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workon }
    end
  end

  # GET /workons/1/edit
  def edit
    @workon = Workon.find(params[:id])
    @usuarios = Usuario.order(:nome)
  end

  # POST /workons
  # POST /workons.json
  def create
    @workon = Workon.new(params[:workon])

    respond_to do |format|
      if @workon.save
        format.html { redirect_to @workon, notice: 'Workon was successfully created.' }
        format.json { render json: @workon, status: :created, location: @workon }
      else
        format.html { render action: "new" }
        format.json { render json: @workon.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workons/1
  # PUT /workons/1.json
  def update
    @workon = Workon.find(params[:id])

    respond_to do |format|
      if @workon.update_attributes(params[:workon])
        format.html { redirect_to edit_workon_path(@workon), notice: 'Workon was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_workon_path(@workon), notice: 'Updated failed: Invalid or duplicated user.' }
        format.json { render json: @workon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workons/1
  # DELETE /workons/1.json
  def destroy
    @workon = Workon.find(params[:id])
    @workon.destroy

    respond_to do |format|
      format.html { redirect_to workons_url }
      format.json { head :no_content }
    end
  end
end
