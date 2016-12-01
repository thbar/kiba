Kiba Pro Changelog
==================

Kiba Pro is the commercial extension for Kiba. [Get in touch](mailto:thibaut.barrere+kiba@gmail.com) for more info on the pricing & licensing.

HEAD
-------

0.9.0
-----

- Multiple improvements to `SQLBulkInsert`:
  - New flexible `row_pre_processor` option which allows to either remove a row conditionally (useful to conditionally target a given destination amongst many) or to replace it by N dynamically computed target rows.
  - New callbacks: `after_initialize` & `before_flush` (useful to enforce dependent destinations flush & ensure required foreign keys constraints are respected).
  - `logger` support.
  - Bugfix: make sure to `disconnect` on `close`.
  - Extra safety checks on row keys.

0.4.0
-----

- Initial release of the `SQLBulkInsert` destination (providing fast SQL INSERT).