Rummageable is a ruby gem to simplify communication with Rummager to
create/update/remove items in the gov.uk search index.

## Example Usage

    artefact_hash = {
      "title"=>"Child benefit tax calculator",
      "format"=>"smart-answer",
      "section"=>nil,
      "subsection"=>nil
    }
    Rummageable.index [artefact_hash]

