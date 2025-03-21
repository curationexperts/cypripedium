# Research Database

![Research Database Logo](app/assets/images/rdlogo.png)

The Research Database is a digital repository designed for public discovery of the research conducted by economists affiliated with the Federal Reserve Bank of Minneapolis Research Division. Publications, data, and conference proceedings constitute the majority of materials. The Research Database uses open source software, [Hyrax](https://github.com/samvera/hyrax), developed by the [Samvera](https://github.com/samvera) community.<br>

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/curationexperts/cypripedium/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/curationexperts/cypripedium/tree/main)
[![Maintainability](https://api.codeclimate.com/v1/badges/a879e476e0002fca69ff/maintainability)](https://codeclimate.com/github/curationexperts/cypripedium/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a879e476e0002fca69ff/test_coverage)](https://codeclimate.com/github/curationexperts/cypripedium/test_coverage)
[![Coverage Status](https://coveralls.io/repos/github/curationexperts/cypripedium/badge.svg?branch=main)](https://coveralls.io/github/curationexperts/cypripedium?branch=main)


## BagIt Functionality

BagIt archives can be created from the command line using the bag rake task:

`USER_ID=1 BAG_PATH=/tmp/bags rake bag:create[publication1,publication2,publication3]`

`USER_ID` is the id of the user that will be notified.

The bag will be located in the directory set by the `ENV['BAG_PATH']` environment variable or you can specify it when running the rake task. It will be named `mpls_fed_research_<time-stamp>.tar` (time stamp being a unix time stamp). The contents of the bag will consist of all the attached files in the specified publications. The created bag will use `sha256` to create checksums for the files.

To download a bag that has been created you can visit the route: `/bag/mpls_fed_research_<time-stamp>.tar`.


## Local Development with Docker

Using docker is the most straightforward way of setting up a local development environment.

1. Install docker for your local environment
2. Check out the cypripedium code base and navigate to that code base: `git clone git@github.com:MPLSFedResearch/cypripedium.git; cd cypripedium`
3. Bring up the docker container: `docker compose up` Once the container has started, you should be able to visit in your browser:

  1. <http://localhost:8983/solr/#/hydra-development> (dev instance of solr)
  2. <http://localhost:8983/solr/#/hydra-test> (test instance of solr)
  3. <http://localhost:8080/rest/> (dev and test instance of fedora)
  4. <http://localhost:3000/> (Your locally running rails application)


### Running the tests

The best way to know that your local development environment is running as expected is to run the automated test suite:

1. In a new terminal window, navigate to your code base
2. Connect to your running rails container: `docker compose exec web bash`
3. Run the test suite: `bundle exec rspec spec`

## Data setup

Whether you use docker or not, there are a few steps necessary to let you interact with your local instance.

1. Generate collection types and admin set:

  ```bash
  bundle exec rails hyrax:default_collection_types:create
  bundle exec rails hyrax:default_admin_set:create
  ```

2. Generate a new user and make them an admin on the console

  ```ruby
  bundle exec rails c
  u = User.new
  u.display_name = "User Name"
  u.email = "email@testdomain.com"
  u.password = "password"
  u.password_confirmation = "password"
  u.save
  admin = Role.create(name: "admin")
  admin.users << u
  admin.save
  ```

  If you then type `u.admin?` it should return `True` if the previous steps were successful.

3. `bundle exec rails s`. In your browser, check to see the application running at `localhost:3000`.

4. In the brower session, log in as the admin user you just created.


## Capistrano deployment

To deploy to the SSM environment, you must have a configured .aws/credentials file, with a profile named "frbm-ssm".

After this is in place, 

```
bundle exec cap ssm deploy
```

Will deploy to the SSM environment.  The deployment system uses tags to determine the instance ids of the relevant target
hosts (SSM does not use ip addresses or the like), based on the value of the ```host_env``` environment variable

For instance, a host with the tags Environment=stage and Project=rdb will be the target of 

```
HOST_ENV=prod bundle exec cap ssm deploy
```

Capistrano defaults to "stage" if HOST_ENV is not set.


## Ansible
When building a new system via Ansible, the "localhost.rb" configuration will be used, and requires
no further steps (other than having frbm-ssm profile set up)

