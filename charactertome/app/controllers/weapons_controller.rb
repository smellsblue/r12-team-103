class WeaponsController < ApplicationController
  before_filter :verify_access_to_weapon

  def create
    result = @tome.create_weapon! params
    render :json => {
      :new_weapon_html => render_to_string(:partial => "/tomes/weapon", :object => result[:weapon], :format => :html)
    }
  end

  def destroy
    raise "Weapon is required!" unless @weapon
    @weapon.destroy
    render :json => {}
  end

  def update
    raise "Weapon is required!" unless @weapon
    render :json => @tome.update_weapon!(@weapon, params)
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
