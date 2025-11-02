# Mushaf App Documentation

This directory contains all project documentation organized into **active** (current) and **archived** (historical/completed) documents.

---

## 📋 Quick Navigation

### Active Documentation

**Note:** The latest architecture review is v5, which has been completed and archived. See `archived/architecture_reviews/` for all historical reviews.

**Active Documentation:**
- [`active/testing-guide.md`](./active/testing-guide.md) - Testing guide and best practices
- [`active/coverage-status.md`](./active/coverage-status.md) - Current test coverage status
- [`active/memorization_feature_spec.md`](./active/memorization_feature_spec.md) - Memorization feature specification (beta)
- [`active/memorization_chaining.md`](./active/memorization_chaining.md) - Memorization chaining design
- [`active/product_analysis_roadmap.md`](./active/product_analysis_roadmap.md) - Product analysis and roadmap

---

## 📦 Archived Documentation

### Architecture Reviews (Historical)
Historical architecture reviews documenting code quality improvements over time:

- [`archived/architecture_reviews/architecture_review.md`](./archived/architecture_reviews/architecture_review.md) - v1 (All issues ✅ COMPLETED)
- [`archived/architecture_reviews/architecture_review_v2.md`](./archived/architecture_reviews/architecture_review_v2.md) - v2 (All issues ✅ COMPLETED)
- [`archived/architecture_reviews/architecture_review_v3.md`](./archived/architecture_reviews/architecture_review_v3.md) - v3 (All issues ✅ COMPLETED)
- [`archived/architecture_reviews/architecture_review_v4.md`](./archived/architecture_reviews/architecture_review_v4.md) - v4 (All issues ✅ COMPLETED)
- [`archived/architecture_reviews/architecture_review_v5.md`](./archived/architecture_reviews/architecture_review_v5.md) - v5 (4 issues ✅ FIXED, 2 ⏸️ DEFERRED) - **Latest review**

---

### Feature Specifications (Completed)
Feature specifications for implemented features:

- [`archived/feature_specs/bookmarks_feature_spec.md`](./archived/feature_specs/bookmarks_feature_spec.md) - ✅ Implemented
- [`archived/feature_specs/reading_progress_feature_spec.md`](./archived/feature_specs/reading_progress_feature_spec.md) - ✅ Implemented
- [`archived/feature_specs/mushaf_reading_feature_spec.md`](./archived/feature_specs/mushaf_reading_feature_spec.md) - ✅ Implemented (core feature)

---

### Planning Documents (Completed)
Completed planning and design documents:

- [`archived/planning/storage_consolidation_plan.md`](./archived/planning/storage_consolidation_plan.md) - ✅ Completed (unified `app_data.db` implemented)
- [`archived/planning/DOCUMENTATION_ORGANIZATION_PROPOSAL.md`](./archived/planning/DOCUMENTATION_ORGANIZATION_PROPOSAL.md) - ✅ Completed (documentation reorganization implemented)

---

### Testing Documentation (Historical)
Historical testing analysis and status documents:

- [`archived/testing/testing_gap_analysis.md`](./archived/testing/testing_gap_analysis.md) - iOS PRAGMA error analysis (historical)
- [`archived/testing/testing-implementation-status.md`](./archived/testing/testing-implementation-status.md) - Historical testing implementation status

**Note:** Current testing documentation is in [`active/testing-guide.md`](./active/testing-guide.md) and [`active/coverage-status.md`](./active/coverage-status.md).

---

## 📁 Directory Structure

```
docs/
├── README.md                              # This file
├── architecture_review_v5.md              # Current architecture review
├── active/                                # Active documentation
│   ├── testing-guide.md
│   ├── coverage-status.md
│   ├── memorization_feature_spec.md
│   ├── memorization_chaining.md
│   └── product_analysis_roadmap.md
└── archived/                              # Historical/completed documentation
    ├── architecture_reviews/              # Historical architecture reviews (v1-v4)
    ├── feature_specs/                     # Completed feature specifications
    ├── planning/                          # Completed planning documents
    └── testing/                           # Historical testing documentation
```

---

## 🔍 Finding Documentation

- **Latest architecture review:** [`archived/architecture_reviews/architecture_review_v5.md`](./archived/architecture_reviews/architecture_review_v5.md) - v5 (completed)
- **Testing guide:** [`active/testing-guide.md`](./active/testing-guide.md)
- **Feature specifications:** See `active/` for active features, `archived/feature_specs/` for completed
- **All architecture reviews:** See `archived/architecture_reviews/` for v1-v5

---

## 📝 Document Organization Principles

- **Active documents** are in `active/` or root (if current/reference docs)
- **Archived documents** are completed or historical but kept for reference
- **Architecture reviews** follow versioning (v1-v5), current version stays in root
- **Feature specs** move to archived when feature is fully implemented
- **Planning docs** move to archived when plan is completed

---

## 🆕 Adding New Documentation

- **Active documentation:** Add to `active/` subdirectory
- **Architecture reviews:** New reviews go in `archived/architecture_reviews/` with next version number (v6, v7, etc.). Once completed, they remain archived.
- **Feature specs:** Add to `active/` until feature is complete, then move to `archived/feature_specs/`
- **Testing docs:** Add to `active/` if current, `archived/testing/` if historical
- **Planning docs:** Add to `active/` until plan is completed, then move to `archived/planning/`

---

## 📚 Related Documentation

- **Architecture:** All reviews in `archived/architecture_reviews/` (v1-v5)
- **Testing:** Active in `active/`, historical in `archived/testing/`
- **Features:** Active in `active/`, completed in `archived/feature_specs/`
- **Planning:** Active in `active/`, completed in `archived/planning/`

