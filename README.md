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
