class TomesController < ApplicationController
  before_filter :load_me, :only => [:me]
  before_filter :ensure_tome, :only => [:me]

  def me
    redirect_to "/tomes/#{@me.id}"
  end

  def show
    @tome = Tome.find params[:id]
  end

  def update
    tome = Tome.find params[:id]
    raise "You do not have permission!" if session[:user_id].to_i != tome.owner_id
    result = tome.update_value!(params)
    return redirect_to tome_path(tome.id) if params[:redirect] == "true"
    render :json => result
  end

  def update_pic
    @tome = Tome.find params[:id]
    raise "You do not have permission!" if session[:user_id].to_i != @tome.owner_id
  end

  private
  def load_me
    unless session[:user_id].present?
      @me = create_new_me!
      return
    end

    @me = User.find session[:user_id].to_i

    unless @me
      @me = create_new_me!
    end
  end

  def create_new_me!
    user = User.create!
    session[:user_id] = user.id
    user
  end

  def ensure_tome
    Tome.create! :owner_id => @me.id unless @me.tome
  end
end
