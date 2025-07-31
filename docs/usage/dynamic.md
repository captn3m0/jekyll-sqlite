---
title: Dynamic DB File
parent: Usage
nav_order: 3
---

If you want to select the database filename via an environment variable,
you can use the following options as a workaround:

## Using `envsubst` from GNU gettext

You can install it via [brew](https://formulae.brew.sh/formula/gettext)
or [on linux](https://repology.org/project/gettext/versions).

First, define your database filename,
and create a new configuration template file.

```sh
export JEKYLL_DB=events-blr.db
cp _config.yml _config.txt
```

Then, use the database name in your new ocnfig file

```yaml
sqlite:
  data: events
  file: $JEKYLL_DB
  query: SELECT * FROM events
```

Then, use `envsubst` to generate the `_config.yml`

```bash
envsubst < "_config.txt" > "_config.yml"
```

## Using multiple configuration files

You can define your `sqlite` parameter multiple times
across multiple files, using different database filenames

For eg, `_config-blr.yml` could only include:

```
sqlite:
  data: events
  file: events-blr.db
  query: SELECT * FROM events
```

And you can run jekyll using `jekyll --config _config.yml,_config-blr.yml`

However, this requires duplicating your query across multiple files.