json.status 200
json.friends_list current_user.friends do |row|
 json.name row.name
 json.email row.email
 json.reecherId row.reecher_id
 json.location row.location
 json.image_url row.image_url
 json.associated_group_ids (current_user.owned_groups.collect(&:id) & row.groups.collect(&:id))
end

json.groups(current_user.owned_groups, :id, :name)
