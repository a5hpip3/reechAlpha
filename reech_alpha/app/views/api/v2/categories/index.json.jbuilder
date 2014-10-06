json.array! Category.all do |category|
  json.id category.id
  json.title category.title
  json.question_count category.questions.all_feed(current_user).count
end
