module TomesHelper
  def can_edit?
    session[:user_id].to_i == @tome.owner_id
  end
end
