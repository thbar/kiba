Kiba Pro Changelog
==================

Kiba Pro is the commercial extension for Kiba. Documentation is available on the [Wiki](https://github.com/thbar/kiba/wiki).

HEAD
-------

- BREAKING CHANGE: deprecate non-live Sequel connection passing (https://github.com/thbar/kiba/issues/79). Do not use `database: "connection_string"`, instead pass your Sequel connection directly. This moves the connection management out of the destination, which is a better pattern & provides better (block-based) resources closing.
- Compatibility with Kiba v3
- Official MySQL support:
  - While the compatibility was already here, it is now tested for in our QA testing suite.
  - MySQL 5.5-8.0 is supported & tested
  - MariaDB should be supported (although not tested against in the QA testing suite)
  - Amazon Aurora MySQL is also supposed to work (although not tested)
  - `Kiba::Pro::Sources::SQL` supports for non-streaming + streaming use
  - `Kiba::Pro::Destinatinons::SQLBulkInsert` supports:
    - Bulk insert
    - Bulk insert with ignore
    - Bulk upsert (including with dynamically computed columns) via `ON DUPLICATE KEY UPDATE`

1.2.0
-----

- `SQL` source improvements:
  - Deprecate use_cursor in favor of block query construct. The source could previously be configured with:

    ```ruby
    source Kiba::Pro::Sources::SQL,
      query: "SELECT * FROM items",
      use_cursor: true
    ```

    The `use_cursor` keyword is now deprecated. You can use the more powerful block query construct:

    ```ruby
    source Kiba::Pro::Sources::SQL,
      query: -> (db) { db["SELECT * FROM items"].use_cursor },
    ```

  - Avoid bogus nested SQL calls when configuring the query via block/proc. A call with:
  
    ```ruby
    source Kiba::Pro::Sources::SQL,
      query: -> (db) { db["SELECT * FROM items"] },
    ```
    
    would have previously generated a `SELECT * FROM (SELECT * FROM "items")`. This is now fixed.

  - Add specs around streaming support (for both MySQL and Postgres).
  
    For Postgres, streaming was [recommended by the author of Sequel](https://groups.google.com/d/msg/sequel-talk/olznPcmEf8M/hd5Ris0pYNwJ) over `use_cursor: true` (but do compare on your actual cases!). To enable streaming for Postgres:
    - Add `sequel_pg` to your `Gemfile`
    - Enable the extension in your `db` instance & add `.stream` to your dataset e.g.:
    
    ```ruby
    Sequel.connect(ENV.fetch('DATABASE_URL')) do |db|
      db.extension(:pg_streaming)
      Kiba.run(Kiba.parse do
        source Kiba::Pro::Sources::SQL,
          db: db,
          query: -> (db) { db[:items].stream }
        # SNIP
      end)
    ```
    
    For MySQL, just add `.stream` to your dataset like above (no extension required).

1.1.0
-----

- Improvement: `SQLBulkInsert` now supports Postgres `INSERT ON CONFLICT` for batch operations (bulk upsert, conditional upserts, ignore if exist etc) via new `dataset` keyword. See [documentation](https://github.com/thbar/kiba/wiki/SQL-Bulk-Insert-Destination).

1.0.0
-----

NOTE: documentation & requirements/compatibility are available on the [wiki](https://github.com/thbar/kiba/wiki).

- New: `SQLUpsert` destination allowing row-by-row "insert or update".
- New: `SQL` source allowing efficient streaming of large volumes of SQL rows while controlling memory consumption.
- Improvement: `SQLBulkInsert` can now be used from a Sidekiq job.

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
