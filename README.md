# CYPRIPEDIUM

<table width="100%">
<tr><td>
<img alt="Cypripedium reginae image" src="app/assets/images/cypripedium.png">
</td><td>
A repository for managing and discovering assets for the Federal Reserve Bank of Minneapolis.
<a href="https://en.wikipedia.org/wiki/Cypripedium_reginae"><em>Cypripedium reginae</em></a>
is a rare, terrestrial, temperate, lady's-slipper orchid native to northern North America. It is the <a href="http://www.dnr.state.mn.us/snapshots/plants/showyladysslipper.html">state flower of Minnesota</a>.
<br/><br/>

[![Build Status](https://travis-ci.org/curationexperts/cypripedium.svg?branch=master)](https://travis-ci.org/curationexperts/cypripedium)      
[![Dependency Status](https://gemnasium.com/badges/github.com/curationexperts/cypripedium.svg)](https://gemnasium.com/github.com/curationexperts/cypripedium)     
[![Coverage Status](https://coveralls.io/repos/github/curationexperts/cypripedium/badge.svg?branch=master)](https://coveralls.io/github/curationexperts/cypripedium?branch=master)    
[![Inline docs](http://inch-ci.org/github/curationexperts/cypripedium.svg?branch=master)](http://inch-ci.org/github/curationexperts/cypripedium)     
[![Stories in Ready](https://badge.waffle.io/curationexperts/cypripedium.png?label=ready&title=Ready)](https://waffle.io/curationexperts/cypripedium)  

</td></tr>
</table>

## Developer Setup

1. Change to your working directory for new development projects   
    `cd .`
1. Clone this repo   
    `git clone https://github.com/curationexperts/cypripedium.git`
1. Change to the application directory  
    `cd cypripedium`
1. Use set your ruby version to **2.4.2** and the gemset of your choice  
    eg. `rvm use --create 2.4.2@cypripedium`
1. Start redis  
    `redis-server &`  
    *note:* use ` &` to start in the background, or run redis in a new terminal session  
1. Start the demo server in its own terminal session
    `bin/rails hydra:server`
1. Run the first time setup script  
    `bin/setup`
1. Run the test suite  
    `bin/rails ci`

## How to create an admin user on the console

1. Connect to the rails console in the production environment and follow this script:
  ```ruby
  RAILS_ENV=production bundle exec rails c
  2.4.2 :001 > u = User.new
  2.4.2 :002 > u.email = "fake@example.com"
  2.4.2 :003 > u.display_name = "Jane Doe"
  2.4.2 :004 > u.password = "123456"
  2.4.2 :005 > admin_role = Role.where(name: 'admin').first_or_create
   => #<Role id: 1, name: "admin">
  2.4.2 :006 > u.roles << admin_role
   => #<ActiveRecord::Associations::CollectionProxy [#<Role id: 1, name: "admin">]>
  2.4.2 :007 > u.save
   => true
  2.4.2 :011 > u.admin?
  Role Exists (0.2ms)  SELECT  1 AS one FROM "roles" INNER JOIN "roles_users" ON "roles"."id" = "roles_users"."role_id" WHERE "roles_users"."user_id" = ? AND "roles"."name" = ? LIMIT ?  [["user_id", 2], ["name", "admin"], ["LIMIT", 1]]
 => true
  ```

1. If the object won't save, or isn't working as expected, you can check the errors like this:
  ```ruby
  2.4.2 :015 > u = User.new
  2.4.2 :016 > u.email = "bess@curationexperts.com"
  2.4.2 :017 > u.save
   => false
  2.4.2 :018 > u.errors.messages
   => {:email=>["has already been taken"], :password=>["can't be blank"], :orcid=>[]}
  ```
