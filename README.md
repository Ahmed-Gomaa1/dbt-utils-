# Surrogate Key Trim

A dbt package that extends the functionality of `dbt_utils.generate_surrogate_key` with a trim parameter.

## Overview

This package provides an enhanced version of the generate_surrogate_key macro that includes the ability to trim whitespace from input fields before hashing. This is particularly useful when dealing with data that may have inconsistent spacing but should be treated as identical values.

## Installation

Include in your `packages.yml`:

```yaml
packages:
  - git: "https://github.com/Ahmed-Gomaa1/dbt-utils-"
    revision: main  # Or use a specific tag like v1.0.0
```

Then run:
```bash
dbt deps
```

## Usage

The package provides the `surrogate_key_trim.generate_surrogate_key` macro with the following signature:

```sql
{{ surrogate_key_trim.generate_surrogate_key(field_list, trim=false) }}
```

### Parameters

- `field_list` (required): A list of fields to be included in the surrogate key
- `trim` (optional, default: `false`): When set to `true`, trims leading and trailing whitespace from string fields before hashing. When `false`, preserves all whitespace in the input fields.

### Example

Basic usage (without trim):
```sql
{{ surrogate_key_trim.generate_surrogate_key(['field_a', 'field_b']) }}
```

Usage with trim enabled:
```sql
{{ surrogate_key_trim.generate_surrogate_key(['field_a', 'field_b'], trim=true) }}
```

When `trim=true`, the macro will remove leading and trailing whitespace from string fields before generating the hash. This is useful when dealing with data that may have inconsistent spacing but should be treated as identical values.

## Why Use This Package?

When working with data that comes from various sources, it's common to encounter inconsistent spacing in string fields. For example:
- `'John Doe'`
- `'John Doe '` (trailing space)
- `' John Doe'` (leading space)
- `' John Doe '` (both leading and trailing spaces)

Without trimming, these would generate different surrogate keys even though they represent the same logical value. This package solves that problem.

## Backward Compatibility

The package maintains full backward compatibility. When `trim=false` (the default), the behavior is identical to the original `dbt_utils.generate_surrogate_key` macro.

## Configuration Variables

This package respects the same configuration variable as the original:
- `surrogate_key_treat_nulls_as_empty_strings`: When set to `true`, treats NULLs as empty strings instead of the default `_dbt_utils_surrogate_key_null_` string.

## Contributing

Feel free to open issues or submit pull requests if you find any problems or have suggestions for improvements.

## License

MIT