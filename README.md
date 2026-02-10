# dbt Surrogate Key Utils

> Enhanced `generate_surrogate_key` with input consistency for parallel dbt pipelines

[![dbt Version](https://img.shields.io/badge/dbt-%3E%3D1.0.0-orange.svg)](https://www.getdbt.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## The Problem

Modern dbt projects use hash-based surrogate keys to enable parallel builds:
```sql
-- Both build independently - no join needed!
-- dim_customers.sql
{{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_sk

-- fct_orders.sql
{{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_sk
```

**But input inconsistency breaks relationships silently:**
```
md5('customer_123')  → 'a7f3c2d1...'  ✅
md5('customer_123 ') → 'x9z7k3m2...'  ❌ One space = different key!
```

## The Solution

This package enhances `dbt_utils.generate_surrogate_key` with automatic input trimming:
```sql
{{ dbt_utils.generate_surrogate_key(
    ['customer_id'],
    trim_whitespace=true  -- ✨ New parameter
) }}
```

✅ Consistency enforced at macro level  
✅ No manual duplication across models  
✅ Safe parallel pipelines by default  
✅ Drop-in replacement for existing code  

---

## Installation

### Step 1: Add Both Packages
```yaml
# packages.yml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  
  - git: "https://github.com/Ahmed-Gomaa1/dbt-surrogate-key-utils"
    revision: v1.0.0  # Use latest release tag
```

### Step 2: Configure Dispatch
```yaml
# dbt_project.yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['dbt_surrogate_key_utils', 'dbt_utils']
```

### Step 3: Install
```bash
dbt deps
```

---

## Usage

### Drop-In Replacement

**Use exactly like `dbt_utils.generate_surrogate_key`:**
```sql
-- No changes needed to function name!
{{ dbt_utils.generate_surrogate_key(
    ['customer_id', 'region'],
    trim_whitespace=true  -- Just add this parameter
) }}
```

### Before vs After

**Before (manual trimming everywhere):**
```sql
-- dim_customers.sql
{{ dbt_utils.generate_surrogate_key(["trim(customer_id)", "trim(region)"]) }}

-- fct_orders.sql
{{ dbt_utils.generate_surrogate_key(["trim(customer_id)", "trim(region)"]) }}

-- fct_returns.sql
{{ dbt_utils.generate_surrogate_key(["trim(customer_id)", "trim(region)"]) }}
```

**After (automatic trimming):**
```sql
-- Everywhere - guaranteed consistent
{{ dbt_utils.generate_surrogate_key(
    ['customer_id', 'region'],
    trim_whitespace=true
) }}
```

### Parallel Pipeline Example
```sql
-- models/dim_customers.sql
select
  {{ dbt_utils.generate_surrogate_key(
      ['customer_id'],
      trim_whitespace=true
  ) }} as customer_sk,
  customer_id,
  customer_name
from {{ ref('stg_customers') }}

-- models/fct_orders.sql (builds in parallel!)
select
  {{ dbt_utils.generate_surrogate_key(
      ['customer_id'],
      trim_whitespace=true
  ) }} as customer_sk,  -- Guaranteed to match!
  order_date,
  amount
from {{ ref('stg_orders') }}
```

**Result:** Both models build independently, keys match perfectly.

---

## How It Works

### Dispatch Pattern

This package uses dbt's [dispatch pattern](https://docs.getdbt.com/reference/dbt-jinja-functions/adapter#dispatch) to override the `dbt_utils.generate_surrogate_key` macro.

**When you call:**
```sql
{{ dbt_utils.generate_surrogate_key(['field']) }}
```

**dbt looks for the macro in this order:**
1. `dbt_surrogate_key_utils` (this package) ← Found! Uses enhanced version
2. `dbt_utils` (fallback) ← Not reached

### What Gets Trimmed

With `trim_whitespace=true`:

| Input | After Trim | Same Hash? |
|-------|------------|------------|
| `'John'` | `'John'` | ✅ |
| `'John '` | `'John'` | ✅ |
| `' John'` | `'John'` | ✅ |
| `' John '` | `'John'` | ✅ |

Without trimming, all four would produce different surrogate keys!

---

## Configuration

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `field_list` | list | required | Fields to include in surrogate key |
| `trim_whitespace` | boolean | `false` | Remove leading/trailing whitespace before hashing |

### Variables

Respects the same variables as `dbt_utils`:
```yaml
# dbt_project.yml
vars:
  surrogate_key_treat_nulls_as_empty_strings: true  # Optional
```

---

## Backward Compatibility

**This package is 100% backward compatible:**

- ✅ Default behavior (`trim_whitespace=false`) identical to original
- ✅ All existing code works without changes
- ✅ Only adds new optional parameter
- ✅ No breaking changes

**Migration is opt-in:**
1. Install package
2. Test with `trim_whitespace=true` in dev
3. Roll out to production when ready
4. Existing code continues working unchanged

---

## Why Not a Fork?

**This package enhances dbt_utils without replacing it:**

| Approach | Maintenance | Updates | Conflicts |
|----------|-------------|---------|-----------|
| **Fork** | Maintain all macros | Manual sync | High risk |
| **This package** ✅ | One macro only | Automatic | No risk |

**Benefits:**
- ✅ Get dbt_utils updates automatically
- ✅ Only this macro is enhanced
- ✅ Minimal maintenance burden
- ✅ Works alongside official dbt_utils

---

## Testing

### Example Test
```sql
with test_data as (
  select 'John' as name, 1 as id
  union all
  select ' John ' as name, 2 as id  -- Same name, extra spaces
)

select
  id,
  name,
  {{ dbt_utils.generate_surrogate_key(['name'], trim_whitespace=false) }} as key_no_trim,
  {{ dbt_utils.generate_surrogate_key(['name'], trim_whitespace=true) }} as key_with_trim
from test_data
```

**Expected results:**
- `key_no_trim`: Different for id 1 and 2
- `key_with_trim`: **Same** for id 1 and 2 ✅

---

## Origin Story

This package started as [PR #1069](https://github.com/dbt-labs/dbt-utils/pull/1069) to dbt_utils.

The maintainers suggested publishing as a standalone package, which allows:
- ✅ Faster iteration and user feedback
- ✅ Broader feature set beyond core scope
- ✅ Immediate availability to teams who need it

---

## Requirements

- dbt >= 1.0.0
- dbt-utils >= 1.0.0

---

## Support

- 🐛 [Open an issue](https://github.com/Ahmed-Gomaa1/dbt-surrogate-key-utils/issues)
- 📧 [Email](mailto:3hmedgomaa2001@gmail.com)

---

## License

MIT - see [LICENSE](LICENSE)

---

## Contributing

Contributions welcome! Please:
1. Open an issue first to discuss changes
2. Follow existing code style
3. Add tests for new features
4. Update documentation

---

**Made with ❤️ for the dbt community**
