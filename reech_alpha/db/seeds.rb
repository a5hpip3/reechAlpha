# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

# CreateCategories 
Category.create(:title => "News")
Category.create(:title => "Sports")
Category.create(:title => "Entertainment")

# InsertCategoryTocategoryMasterTable
Category.create([{:title => "Arts & Culture"},
    {:title => "Cars & Bikes"},
    {:title => "Community Events"},
    {:title => "Education & Hobbies"},
    {:title => "Family & Pets"},
    {:title => "Financial"},
    {:title => "Food & Dining"},
    {:title => "Health, Sports & Fitness"},
    {:title => "Home Improvement"},
    {:title => "Personal & Professional Services"},
    {:title => "Technology"},
    {:title => "Travel & Other"}])
