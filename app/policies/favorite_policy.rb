class FavoritePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # authenticated user can only see his/her own favorites
      scope.where(user: user)
    end
  end

  def create?
    # authenticated user can create favorite
    return true
  end
end
