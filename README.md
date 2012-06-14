# Mongoid::Max::Denormalize

`Mongoid::Max::Denormalize` is a denormalization extension for Mongoid.

It was designed for a minimum number of queries to the database.

For now, support only Mongoid 3.

* Propagate only when needed
* Take advantage of atomic operations on multi documents of MongoDB

*This is a pre-version not suitable for production.*



## Installation

Add the gem to your Gemfile:

    gem 'mongoid_max_denormalize'

Or install with RubyGems:

    $ gem install mongoid_max_denormalize



## Usage

### Basic usage

Add `include Mongoid::Max::Denormalize` in your model and also:

    denormalize relation, field_1, field_2 ... field_n, options


### One to Many

**Supported fields:** normal Mongoid fields, and methods.

**Supported options:** none.

Example :

    class Post
      include Mongoid::Document

      field :title

      def slug
        title.try(:parameterize)
      end

      has_many :comments
    end

    class Comment
      include Mongoid::Document
      include Mongoid::Max::Denormalize

      belons_to :post
      denormalize :post, :title, :slug
    end

    @post = Post.create(:title => "Mush from the Wimp")
    @comment = @post.comments.create
    @comment.post_title #=> "Mush from the Wimp"
    @comment.post_slug  #=> "mush-from-the-wimp"

    @post.update_attributes(:title => "All Must Share The Burden")
    @comment.reload     # to reload the comment from the DB
    @comment.post_title #=> "All Must Share The Burden"
    @comment.post_slug  #=> "all-must-share-the-burden"

**Tips :** In your views, do not use `@comment.post` but `@comment.post_id` or `@comment.post_id?`
to avoid a query that checks/retrieve for the post. We want to avoid it, don't we ?

Exemple : Check your logs, you'll see queries for the post :

    # app/views/comments/_comment.html.erb
    <div class="comment">
      <% if @comment.post %>
        <%= link_to @comment.post_title, @comment.post %>
      <% end %>
    </div>

This is better :

    # app/views/comments/_comment.html.erb
    <div class="comment">
      <% if @comment.post_id? %>
        <%= link_to @comment.post_title, post_path(@comment.post_id, :slug => @comment.post_slug) %>
      <% end %>
    </div>


### Many to One

**Supported fields:** *only* normal Mongoid fields (no methods)

**Supported options:**

*   `:count => true` : to keep a count !


Example :

    class Post
      include Mongoid::Document
      include Mongoid::Max::Denormalize

      has_many :comments
      denormalize :comments, :rating, :stuff, :count => true
    end

    class Comment
      include Mongoid::Document

      belons_to :post

      field :rating
      field :stuff
    end

    @post = Post.create(:title => "J'accuse !")
    @comment = @post.comments.create(:rating => 5, :stuff => "A")
    @comment = @post.comments.create(:rating => 3, :stuff => "B")
    @post.reload
    @post.comments_count  #=> 2
    @post.comments_rating #=> [5, 3]
    @post.comments_stuff  #=> ["A", "B"]

You can see that each denormalized field in stored in a separate array. This is wanted.
An option `:group` will come to allow :

    @post.comments_fields #=> [{:rating => 5, :stuff => "A"},{:rating => 5, :stuff => "B"}]


### Many to One

To come...



## Contributing

Contributions and bug reports are welcome.

Clone the repository and run `bundle install` to setup the development environment.

Provide a case spec according to your changes/needs, taking example on existing ones (in `spec/cases`).

To run the specs:

    bundle exec rspec



## Credits

*   Maxime Garcia [emaxime.com](http://emaxime.com) [@maximegarcia](http://twitter.com/maximegarcia)


[License](https://github.com/maximeg/mongoid_max_denormalize/blob/master/LICENSE)
\- [Report a bug](https://github.com/maximeg/mongoid_max_denormalize/issues).

