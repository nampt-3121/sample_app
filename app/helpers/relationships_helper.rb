module RelationshipsHelper
  def relationship_constructor
    current_user.active_relationships.build
  end

  def get_relationship followed_id
    current_user.active_relationships.find_by(followed_id: followed_id)
  end
end
