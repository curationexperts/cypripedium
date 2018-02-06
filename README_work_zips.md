## Downloading a Zip File for a Work

### How the user can download a zip file

When the user is viewing the show page for a work, there is a link for them to download a zip file that contains all the files attached to that work.

If the zip file hasn't been built for this work yet, then there will be a button that the user can press to build the zip.  The user will get a message that a background job has been queued to build the zip, and they should check back in a few minutes.

When the user reloads the page, if the background job isn't finished yet, instead of the download link, the user will see a message that the job isn't finished, and they should check back in a few minutes.

### Assumptions

* Any user can download a zip file, even if they aren't logged in.  Since all works in the current collections have public visibility, the `WorkZipsController` doesn't check to see if the user has the right to download or build a zip file.  In the future, if you add any works that don't have public visibility, you'll need to add some access controls to the controller and some specs to make sure that only authorized users can download the zip.

* The zip file will not be automatically built for a work.  A zip file won't be built unless a user presses the button to build a new zip file.  So, most works won't have a zip file available.

* We expect to have a cleanup task running on the production server that cleans up older zip files.  For example, if the task deletes all zip files older than 7 days, then the zip file will no longer be available for the user to download.  (But the user can build a new zip file by pressing the button on the work's show page.)  If you want a zip file that is 'fresher' than 7 days old, you can manually delete the existing zip file, and then the user will have the option to build a new one.

* If there is some kind of problem building the zip file, it will raise an exception.  That will cause the background job to fail.  If the background jobs are configured to retry after a failure, there might be several attempts to build the zip file.  In that case, the download link won't appear on the work show page, but the button to build a new zip should appear, so the user can try again.  (If it fails after another try, I would expect that a developer will need to look at the errors to figure out what is wrong.)

### Config

You can configure the root directory where Rails will put the zip files by setting an environment variable in the shell that runs the Sidekiq workers.  If you don't set the environment variable, the zips will be placed in a default location.  See the `path_root` method in [the WorkZip class](app/models/work_zip.rb)

```bash
export CYPRIPEDIUM_ZIP_DIR="/Users/valerie/work/dce/projects/fed_reserve/cypripedium/tmp/zips"
```

### More Info

See the comments in [the WorkZip class](app/models/work_zip.rb)

