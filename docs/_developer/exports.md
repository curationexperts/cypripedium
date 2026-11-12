# ZIP and BagIt Exports
This document provides additional technical and development context for the user-facing features 
described in the [Exports](../features/exports.md) feature documentation.

## Overview

> **Terminology:** UI labels may vary in wording and capitalization ("ZIP", "Zip", "Plain Zip";
> "Bag", "BagIt"). These are interchangeable and are not discrepancies.


## UI
If an export with the same works already exists, regardless of format, the **Export Options** page shows a 
warning that lists the existing exports and their format. You can still create a new export.


## Notifications
Administrators will get a notification when their submitted export finishes.
- **Export completed** includes the download link and a count of works exported or excluded due to visibility filtering
  or errors. (This number will always be less than or equal to the number of works initially selected for export).
- **Export failed** includes the error message.

## Visibility filtering
**Implementation NOTE:** 
- UI labels map to internally stored Hyrax visibility values as follows:

  | UI label | Stored value |
  |----------|--------------|
  | FRBM     | `authenticated` |
  | Private  | `restricted` |
- "FRBM" is the configured institution name (`hyrax.institution_name`). `VisibilityLabel.for` produces
   the same text as `Hyrax::PermissionBadge`.
- Filtering lives in `ExportPackager::VISIBILITY_FILTER` and applies to both formats.
- Download permissions are in `Ability`. "authenticated" means a persisted user, not a Hyrax guest user.
- `authenticated` works do not currently occur in production data, so we don't need feature-level testing. 
   We should also minimize unit testing related to the `authenticated` visibility level.

**Implementation Details**
- Exports are stored in the database as `Export` records, which are stored in the `exports` table.
- Downloadable archive files are attached to `Export` records as ActiveStorage attachments (`export_file`)
- Exports are built in the background by `ExportJob`, which hands off to `ExportPackager`.

> **Implementation Details**
> Download links use `GET /exports/downloads/:id` (`export_download_path`). The route sits outside
> `/admin` so that shared links don't expose admin URLs. It redirects to the Active Storage file.

## CSV metadata file
> **Implementation Details**
> - Columns are defined in `ExportPackager::METADATA_HEADERS`.
> - `creator` uses `CreatorNames.normalized_names`.
> - URLs are built with `config.rdf_uri` as the host.
> - `path` never includes the top-level export folder name.

## Export file names
If you leave **Output file name** blank, the export is named
`frbm_<format>_<first work ID>`, for example `frbm_zip_abc123.zip`. The top-level folder inside
the archive has the same name.
A custom name must start with a letter, can contain only letters,
numbers, periods, hyphens, and underscores, and can be up to 250 characters long.

> **Implementation Details**
> - The default comes from `Export#default_filename`. 
> - The default uses the fixed prefix `frbm`.
> - "First work ID" means first after sorting, because export items are stored sorted.
> - The placeholder uses the default export format (ZIP).
> - The placeholder is not updated when format radio buttons are changed.

## Limitations
- Only **Publication**, **Dataset**, and **Conference Proceeding** works can be exported. 
  If you select any other kind of item, that item will only have an entry in the metadata spreadsheet
  indicating it was not included.
- Exports are snapshots. Later changes to a work don't update an export that already exists. Create a
  new export to pick up changes.