# ZIP and BagIt Exports

## Overview
This feature allows administrators to package the files and metadata for one or more works into a single downloadable
compressed `.zip` archive. Two formats are available:

| Format  | Best for                                                          | What you get |
|---------|-------------------------------------------------------------------|--------------|
| **ZIP** | Sharing with researchers, colleagues, or the public               | A folder for each work, its files, and a `metadata.csv` spreadsheet |
| **Bag** | Preservation, transfer to other systems, and automated processing | Everything in a ZIP export, plus checksums and per-work JSON metadata in the standard BagIt layout |

## Creating Exports
1. In the dashboard, go to the **Works** tab.
2. Choose the works to include:
    - Click the checkbox next to each work you want to include.
    - Then click the "**Export Selected**" button at the top of the list.
    - On the **Export Options** page, set:
        - **Output file name** (optional). Leave it blank to use the default name shown in the box 
          (see [File names](#export-file-names)). A custom name must start with a letter, can contain only letters,
          numbers, periods, hyphens, and underscores, and can be up to 250 characters long.
        - **Format:** ZIP (default) or Bag (BagIt)
        - **Visibility:** Public, or Private (see [Choosing visibility](#choosing-visibility)).
      >If an export with the same works already exists, the **Export Options** page shows a warning that lists the
      existing exports. You can still create a new export.
3. Click **Submit Export Job**. You'll be taken to the **Exports** page, where the new export shows as *queued*.

**NOTE:** There is also an express single item export option accessed from the **Actions** menu in each work row. 
Choosing **Create BagIt Export** or **Create ZIP Export** from the actions menu will immediately create an export for
that work. This option bypasses the confirmation options: the format is chosen based on the link; and the visibility is
set to match the work's visibility. Using the express export option does not permit customizing the file name and does
not provide a duplication check or warning.

## Choosing visibility
The visibility you choose controls which works and files are included in your export. Additionally, any user can
download "Public" zip exports: this allows us to build the single item archives provided on each work's show page.

| Export visibility | Works and files included | Who can download |
|---|---|---|
| **Public** | Public only | *ZIP:* Anyone with the link, signed in or not \| *Bag:* Administrators only |
| **Private** | Public, FRBM, and Private | Administrators only |

- Work and File visibility is checked independently. If a work does not meet the export visibility level, the work and
  all of its files are left out. If a work is included, each file is checked independently; only files meeting 
  the visibility criteria are included.
- If a work is included, it will get a row in `metadata.csv`, even if it has no files that meet visibility criteria.
- If a file is included, it will get a row in `metadata.csv`.

    > **Implementation NOTE:** 
    > - UI labels map to internally stored Hyrax visibility values as follows:
    >
    >     | UI label | Stored value |
    >     |----------|--------------|
    >     | Public   | `open`       |
    >     | FRBM     | `authenticated` |
    >     | Private  | `restricted` |
    > - "FRBM" is the configured institution name (`hyrax.institution_name`). `VisibilityLabel.for` produces
        the same text as `Hyrax::PermissionBadge`.
    > - Filtering lives in `ExportPackager::VISIBILITY_FILTER` and applies to both formats.
    > - Download permissions are in `Ability`. "authenticated" means a persisted user, not a Hyrax guest user.

## Tracking and managing exports
Click **Exports** in the Dashboard sidebar to open the **Exported Archive Files** page. Each export shows:

- **ID** and **Items**: click either one to see the works selected for the export.
- **Processed:** when the export last changed status.
- **Status:**
    - *queued*: waiting to start.
    - *working*: being built.
    - *completed*: ready to download.
    - *failed*: something went wrong, and no file was created.
- **Submitted by** the administrator who created the export.
- **Format** zip or bag.
- **Visibility** the visibility level of items included in the export (see [Choosing visibility](#choosing-visibility)).
- **File:** the download link, shown once the export completes.
- **Delete:** available once the export is no longer queued or working.

Administrators will get a notification when their submitted export finishes. 
- **Export completed** includes the download link and the actual number of works exported based on the visibility filter
  (This number will always be less than or equal to the number of works initially selected for export). 
- **Export failed** includes the error message.

    > **Implementation Details**
    > - The work count in the notification is the number of works that passed visibility filtering, not
        the number selected.
    > - Exports are built in the background by `ExportJob`, which hands off to `ExportPackager`.

## Sharing download links
The **File** link on the Exports page can be shared. Whether someone can open it depends on the format
and visibility rules above. People who aren't allowed see a "page not found" error.

> **Implementation Details**
> Download links use `GET /exports/downloads/:id` (`export_download_path`). The route sits outside
> `/admin` so that shared links don't expose admin URLs. It redirects to the Active Storage file.

## What's in a ZIP export
```
my_export/
├── metadata.csv
├── abc123/                 ← a work with one file
│   └── sr887.pdf
├── def456/                 ← a work with several files
│   ├── 1/
│   │   └── wp345.pdf
│   ├── 2/
│   │   └── appendix.pdf
│   └── 3/
│       └── source_data.csv
└── ghi789/                 ← a work with 10 or more files
    ├── 01/
    │   └── readme.txt
    ├── …
    └── 12/
        └── fiscal_data.xls
```
- Each work gets a folder named after its **work ID**, the code at the end of the work's web address.
- A work with **one** file has that file directly inside its folder.
- A work with **several** files has each file in its own numbered folder: 1, 2, 3, and so on.
    - Numbering reflects the order displayed on the work's display page.
    - Numbering only counts files that are in the export. Files left out by visibility filtering don't
      take up a number.
    - Numbers are padded with leading zeros as necessary to preserve the correct sorting order.
- Files keep their original file names. (Two files with the same name may be attached to a single work; they will have 
  different subfolder numbers.)
- Only a work's own files are exported. Child works are not included in their parent's folder.

## What's in a Bag export
A Bag export follows the [BagIt specification](https://www.rfc-editor.org/rfc/rfc8493). The work folders
are laid out exactly as in a ZIP export, but they sit inside a `data/` folder. The bag adds checksum manifests and a
`metadata/` folder with a JSON metadata file for each work:
```
my_export/
├── bagit.txt
├── bag-info.txt
├── manifest-sha256.txt     ← a checksum for every file in data/
├── tagmanifest-*.txt
├── metadata.csv
├── data/
│   └── abc123/
│       └── sr887.pdf
└── metadata/
    └── abc123.json         ← one JSON file per work

```

## The metadata.csv spreadsheet
Both formats include `metadata.csv` at the top level of the export.

- Each included work has **one row**, followed by **one row for each of its included files**. The group of rows for 
  each work and its associated files are separated from the next work with a blank row.
- Works are listed **in order of work ID**, not in the order you selected them. A work's files follow
  the file order shown on the work page.
- Fields with more than one value (titles, creators, and so on) are separated with `|`.
- Dates use the format `YYYY-MM-DD`.

| Column | Work row | File row |
|---|---|---|
| `internal_id` | Work ID | ID of the work the file belongs to |
| `member_id` | (blank) | File ID |
| `type` | Work type (`Publication`, `Dataset`, `ConferenceProceeding`) | `File` |
| `visibility` | Public / FRBM / Private | Public / FRBM / Private |
| `representative_id` | ID of the work's representative file | (blank) |
| `title`, `creator`, `corporate_author`, `date_created`, `date_modified`, `identifier`, `series`, `issue_number`, `collection`, `abstract`, `table_of_contents` | From the work's metadata | (blank) |
| `date_uploaded` | Date the work was uploaded | Date the file was uploaded |
| `location_url` | Link to the work page | Link to download the file |
| `filename` | (blank) | File name |
| `path` | (blank) | Where the file is inside the export. ZIP: `abc123/1/wp345.pdf`. Bag: `data/abc123/1/wp345.pdf`. |

> **Implementation Details**
> - Columns are defined in `ExportPackager::METADATA_HEADERS`.
> - `creator` uses `CreatorNames.normalized_names`.
> - URLs are built with `config.rdf_uri` as the host.
> - `path` never includes the top-level export folder name.

## Export file names
If you leave **Output file name** blank, the export is named
`frbm_<format>_<first work ID>`, for example `frbm_zip_abc123.zip`. The top-level folder inside
the archive has the same name.

> **Implementation Details**
> - The default comes from `Export#default_filename`, using the prefix in `config.bag_prefix`.
> - "First work ID" means first after sorting, because export items are stored sorted.

## Limitations
- Only **Publication**, **Dataset**, and **Conference Proceeding** works can be exported. If you select
  any other kind of item, the whole export fails, and the error appears in the failure notification.
- Exports are snapshots. Later changes to a work don't update an export that already exists. Create a
  new export to pick up changes.