# Changelog

## [1.0.0] - 2026-02-10

### Added
- Enhanced `generate_surrogate_key` macro with `trim` parameter
- When `trim=true`, the macro removes leading and trailing whitespace from string fields before hashing
- Maintains backward compatibility with `trim=false` (default behavior)
- Comprehensive documentation and usage examples
- Example test models for validation

### Changed
- Extended the original `dbt_utils.generate_surrogate_key` functionality
- Preserved all original behavior when trim parameter is not used

### Fixed
- Proper handling of whitespace variations in input data
- Consistent hashing for logically identical values with different spacing