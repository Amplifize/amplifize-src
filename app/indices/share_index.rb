ThinkingSphinx::Index.define :share, :with => :active_record do
    indexes summary
    indexes comments.comment_text, as: :comment_text
    indexes post.title, as: :post_title
    indexes post.content, as: :post_text
end