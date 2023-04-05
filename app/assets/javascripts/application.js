// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//=
//= require turbolinks
//

// Required by Blacklight
//= require jquery
//= require tether
/* removed b/c it currently breaks modals */
// require browse_everything
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require blacklight/blacklight
//= require bootstrap-sprockets
//= require jquery-ui/widgets/autocomplete
//= require_tree "./bag/"
//= require_tree "./channels/"
//= require blacklight_gallery
//= require cable
//= require notification-sort
//= require openseadragon
//= require hyrax
//= require almond
//= require creator_id
//= require hydra-editor/field_manager
//= require 'blacklight_range_limit'
//= require email_register
//= require statistics

bagButton.bindClick({'compression': 'zip'})


// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//
//= require 'blacklight_range_limit'



// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'
//
