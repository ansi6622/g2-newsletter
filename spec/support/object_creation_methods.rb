module ObjectCreationMethods

  def create_user(attributes = {})
    user = new_user(attributes)
    user.save!
    user
  end

  def new_user(attributes = {})
    defaults =
      {
        :email => "user#{counter}@gmail.com",
        :password => 'password',
        :password_confirmation => 'password',
        :admin => false,
      }
    User.new(defaults.merge(attributes))
  end

  def create_publication(attributes = {})
    publication = new_publication(attributes)
    publication.save!
    publication
  end

  def new_publication(attributes = {})
    defaults =
      {
        :name => "Name#{counter}",
        :description => 'Description'

      }
    Publication.new(defaults.merge(attributes))
  end

  def new_subscription(user_id, publication_id)
    Subscription.new(user_id: user_id, publication_id: publication_id)

  end

  def create_subscription(user_id, publication_id)
    Subscription.create!(user_id: user_id, publication_id: publication_id)
  end

  def counter
    @counter ||= -1
    @counter += 1
  end

  def create_article(attributes = {})
    defaults = {
      title: "Article Title",
      description: "Article Description",
      publication_id: Publication.last.id
    }
    Article.create(defaults.merge(attributes))
  end

end
