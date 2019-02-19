# Research Database

<table width="100%">
<tr><td width="50%">
<img alt="Research Database Logo" src="app/assets/images/rdlogo.png">
</td><td width="50%">
The Research Database is a digital repository designed for public discovery of the research conducted by economists affiliated with the Federal Reserve Bank of Minneapolis Research Division. Publications, data, and conference proceedings constitute the majority of materials. The Research Database uses open source software, <a href="https://github.com/samvera/hyrax">Hyrax</a>, developed by the <a href="https://github.com/samvera">Samvera</a> community.
<br/><br/>

[![Build Status](https://travis-ci.org/MPLSFedResearch/cypripedium.svg?branch=master)](https://travis-ci.org/MPLSFedResearch/cypripedium)
[![Coverage Status](https://coveralls.io/repos/github/MPLSFedResearch/cypripedium/badge.svg?branch=master)](https://coveralls.io/github/MPLSFedResearch/cypripedium?branch=master)


</td></tr>
</table>

## BagIt Functionality

BagIt archives can be created from the command line using the bag rake task:

`USER_ID=1 BAG_PATH=/tmp/bags rake bag:create[publication1,publication2,publication3]`

`USER_ID` is the id of the user that will be notified.

The bag will be located in the directory set by the `ENV['BAG_PATH']` environment
variable or you can specify it when running the rake task. It will be named `mpls_fed_research_<time-stamp>.tar` (time stamp being a unix time stamp). The contents of the bag will consist of all the attached files in
the specified publications. The created bag will use `sha256` to create checksums for
the files.

To download a bag that has been created you can visit the route: `/bag/mpls_fed_research_<time-stamp>.tar`.

## Local Development

### Running in postgres
Because we use the postgresql database in production, we follow the rails recommendation and also use it in development. The easiest way to set up a local development instance:
1. Install postgresql
2. Set it up to allow local password-less connections (follow [this guide](https://gist.github.com/p1nox/4953113))
3. Run `bundle exec rake db:setup` to create expected databases and run database migrations
