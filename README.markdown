Maintain
===

**Maintain** is a simple state machine mixin for Ruby objects. It supports comparisons, bitmasks,
and hooks that really work. It can be used for multiple attributes and will always do its best to
stay out of your way and let your code drive the machine, and not vice versa.

Installation
-

**Maintain** is provided as a Gem. It's pretty basic, really:

1. Install it with `gem install maintain`
2. Require it with `require "maintain"`

Basic Usage
-

**Maintain** is pretty straightforward to use. First, you have to tell a Ruby object to maintain
state on an attribute:

```ruby
class Foo
  extend Maintain
  maintains :state do
    state :new, :default => true
    state :old
  end
end
```

That's it for basic state maintenance! Check it out:

```ruby
foo = Foo.new
foo.state			#=> :new
foo.new?			#=> true
foo.state = :old
foo.old?			#=> true
```

But wait! What if you've already defined "new?" on the Foo class? Not to worry, Maintain won't step on your toes. Just use:

	foo.state.new?

And when you *want* Maintain to step on your toes? You can add an optionally add:

	state :new, :force => true

...and Maintain will make sure your methods get added, even if it overwrites a previous method.

**UPDATE: Maintain** now supports `bang!` style methods for declaring a state imperatively. It's as simple as calling

```ruby
foo = Foo.new
foo.old!
foo.state #=> :old
```

Comparisons
-

**Maintain** provides quick and easy comparisons between states. By default, it uses the order in which you add states to
rank them. From our example above:

```ruby
foo.state = :new
foo.state > :old	#=> false
foo.state < :old	#=> true
```

As an optional second argument to `state`, you can specify a comparison value. This will allow you to define states in any
order you want:

```ruby
class Foo
  extend Maintain
  maintains :state do
    state :new, 12, :default => true
    state :old, 5
  end
end

Foo.new.state > old	#=> true
```

Hooks
-

**Maintain** can hook into state entry and exit, and provides a number of mechanisms for doing so:

```ruby
class Foo < ActiveRecord::Base
  maintains :state do
    state :active, :enter => :activated
    state :inactive, :exit => lambda { self.bar.baz! }
  end

  def activated
    puts "I'm alive!"
  end
end
```

Of course, maybe that's not your style. Why not try this?

```ruby
class Foo
  extend Maintain
  maintains :state do
    state :active
    state :inactive

    on :enter, :active, :activated
    on :exit, :inactive do
      bar.baz!
    end
  end

  def activated
    puts "I'm alive!"
  end
end
```


Aggregates
-

What about when a group of states is needed? Yeah, you could write `foo.bar? || foo.baz?`. You could even make that a method!
But why not just add the following?

```ruby
class Foo
  extend Maintain
  maintains :state do
    state :new
    state :old
    state :borrowed
    state :blue

    aggregate :starts_with_b, [:borrowed, :blue]
  end
end

foo = Foo.new
foo.status = :borrowed
foo.starts_with_b?		#=> true
```

Bitmasking
-

Sometimes you need to store a simple combination of values. Sure, you could add individual columns for each value to your
relational database - or you could implement a single bitmask column:

```ruby
class Foo
  extend Maintain
  maintains :state, :bitmask => true do
    # NOTE: Maintain will try to infer a bitmask value if you do not provide an integer here,
    # but if you don't -- and you re-order your state calls later -- all stored bitmasks will
    # be invalidated. You have been warned.
    state :new, 1
    state :old, 2
    state :borrowed, 3
    state :blue, 4
  end
end

foo = Foo.new
foo.state 						#=> nil
foo.state = [:new, :borrowed]
foo.state 						#=> [:new, :borrowed]
foo.new? 						#=> true
foo.borrowed? 					#=> true
foo.blue? 						#=> false
foo.blue!
foo.blue? 						#=> true

# foo.state will boil happily down to an integer when you store it.
```

You can also set multiple defaults on bitmasks, just in case your defaults involve some complicated mix of options:

```ruby
class Foo
  extend Maintain
  maintains :state, :bitmask => true do
    state :new, 1, :default => true
    state :old, 2
    state :borrowed, 3, :default => true
    state :blue, 4
  end
end

foo = Foo.new
foo.new? 						#=> true
foo.old? 						#=> false
foo.borrowed? 					#=> true
foo.blue? 						#=> false
```

Named Scopes
-

**Maintain** knows all about ActiveRecord - it even extends ActiveRecord::Base by default. So it stands to reason that adding states
and aggregates will automatically create named scopes on ActiveRecord::Base subclasses for those states! Check it:

```ruby
class Foo < ActiveRecord::Base
  maintains :state do
    state :active
    state :inactive
  end
end

Foo.active		#=> []
Foo.inactive	#=> []
```
