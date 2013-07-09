# Rummageable

Rummageable is a ruby gem to simplify communication with Rummager to
create/update/remove items in the gov.uk search index.

It attempts to handle networking errors by retrying failed requests a
few times before it'll give up, and will optionally log it's
success/failure to a logger object (if you give it one).

## Usage

To interact with Rummager, create an instance of the `Rummageable::Index`
class:

    index = Rummageable::Index.new('http://localhost:3009', 'index-name')

You can also pass a logger to `new`, and can control how aggressively
Rummageable will retry your command in the event of an error. See the
source for details.

### Getting started

You can add individual indexable "things" to a Rummager index by passing
a hash that represents the thing you want to index:

    document = {
      'title' => 'Child benefit tax calculator',
      'link' => '/child-benefit-tax',
      'format' => 'smart-answer',
      'section' => nil,
      'subsection' => nil
    }
    index = Rummageable::Index.new('http://localhost:3009', 'index-name')
    index.add(document)

The `link` key is special; you can use it to amend/delete the document's
entry in the index later, with the `Index#amend` and `Index#delete`
methods.

If you've got a large collection of documents the `add_batch` method
will chop the collection up into manageable chunks and send them to
Rummager for you.

    index.add_batch(array_of_documents)

See the source of the `Rummageable::Index` class for other methods.
