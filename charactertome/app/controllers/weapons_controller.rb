class WeaponsController < ApplicationController
  before_filter :verify_access_to_weapon

  def create
    result = @tome.create_weapon! params
    render :json => {
      :new_weapon_html => render_to_string(:partial => "/tomes/weapon", :object => result[:weapon], :format => :html)
    }
  end

  def destroy
    render :json => {}
  end

  def update
    render :json => {}
  end

  private
  def verify_access_to_weapon
    @tome = Tome.find params[:tome_id]
    raise "You do not have permission!" if session[:user_id].to_i != @tome.owner.id

    if params[:id].present?
      @weapon = @tome.weapons.find params[:id]
      raise "That is not the right weapon id!" if @weapon.tome_id != @tome.id
    end
  end
end
