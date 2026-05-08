# Phraser App - Categories List

**API Endpoint:** `https://phraser.amazingonlinecourse.com/api/v1/api.php?get_categories`

**Last Updated:** October 16, 2025

**Total Categories:** 38

---

## Complete Categories List

| ID | Category Name | Section | Type | Total Phrasers |
|---|---|---|---|---|
| 51 | Moving On | Acquire knowledge and wisdom | Free | 302 |
| 50 | Patience | Improve peace of mind | Free | 299 |
| 49 | Biblical Verses | God's Blessing | Free | 152 |
| 48 | Parenting | Rejoice with your family | Free | 466 |
| 47 | Quiet People | Acquire knowledge and wisdom | Free | 416 |
| 46 | Trust | Relationship | Free | 524 |
| 45 | Respect | Improve peace of mind | Free | 472 |
| 44 | Running | Health & Fitness | Free | 491 |
| 43 | Kindness | Improve peace of mind | Free | 447 |
| 42 | Body Positivity | Health & Fitness | Paid | 107 |
| 41 | Self Respect | Most Popular | Free | 100 |
| 40 | Dream | Improve peace of mind | Free | 100 |
| 39 | Rain | Connect with nature | Free | 192 |
| 38 | Wisdom | Trending this week | Free | 100 |
| 37 | Motivation | Improve peace of mind | Paid | 99 |
| 36 | Healthier Life | Health & Fitness | Paid | 99 |
| 35 | Hard Times | Most Popular | Free | 416 |
| 34 | Girlfriend | Relationship | Paid | 502 |
| 33 | Boyfriend | Relationship | Free | 499 |
| 32 | Mother | Rejoice with your family | Free | 362 |
| 31 | Father | Rejoice with your family | Paid | 513 |
| 30 | Family | Rejoice with your family | Free | 504 |
| 29 | Failure | Acquire knowledge and wisdom | Free | 496 |
| 28 | Success | Acquire knowledge and wisdom | Paid | 525 |
| 27 | Anniversary | Relationship | Free | 369 |
| 26 | Marriage | Relationship | Free | 534 |
| 25 | Sunshine | Connect with nature | Paid | 520 |
| 24 | Romantic | Relationship | Paid | 508 |
| 23 | Basketball | Sports | Free | 497 |
| 22 | Football | Sports | Free | 513 |
| 21 | Cat love | Pets | Free | 488 |
| 20 | Ocean | Connect with nature | Free | 206 |
| 19 | Dog love | Pets | Free | 376 |
| 18 | Leadership | Acquire knowledge and wisdom | Free | 200 |
| 13 | Personal Growth | Most Popular | Free | 201 |
| 12 | Self Love | Improve peace of mind | Paid | 200 |
| 11 | Gym | Health & Fitness | Free | 103 |
| 10 | True Love | Trending this week | Paid | 106 |

---

## Summary Statistics

- **Total Categories:** 38
- **Free Categories:** 27
- **Paid Categories:** 11
- **Total Phrasers:** ~12,860

---

## Categories by Section

### Most Popular (2 categories)
- ID 41: Self Respect (Free) - 100 phrasers
- ID 35: Hard Times (Free) - 416 phrasers

### Trending this week (2 categories)
- ID 38: Wisdom (Free) - 100 phrasers
- ID 10: True Love (Paid) - 106 phrasers

### Improve peace of mind (7 categories)
- ID 50: Patience (Free) - 299 phrasers
- ID 45: Respect (Free) - 472 phrasers
- ID 43: Kindness (Free) - 447 phrasers
- ID 40: Dream (Free) - 100 phrasers
- ID 37: Motivation (Paid) - 99 phrasers
- ID 12: Self Love (Paid) - 200 phrasers

### Acquire knowledge and wisdom (5 categories)
- ID 51: Moving On (Free) - 302 phrasers
- ID 47: Quiet People (Free) - 416 phrasers
- ID 29: Failure (Free) - 496 phrasers
- ID 28: Success (Paid) - 525 phrasers
- ID 18: Leadership (Free) - 200 phrasers

### Relationship (7 categories)
- ID 46: Trust (Free) - 524 phrasers
- ID 34: Girlfriend (Paid) - 502 phrasers
- ID 33: Boyfriend (Free) - 499 phrasers
- ID 27: Anniversary (Free) - 369 phrasers
- ID 26: Marriage (Free) - 534 phrasers
- ID 24: Romantic (Paid) - 508 phrasers

### Rejoice with your family (4 categories)
- ID 48: Parenting (Free) - 466 phrasers
- ID 32: Mother (Free) - 362 phrasers
- ID 31: Father (Paid) - 513 phrasers
- ID 30: Family (Free) - 504 phrasers

### Health & Fitness (4 categories)
- ID 44: Running (Free) - 491 phrasers
- ID 42: Body Positivity (Paid) - 107 phrasers
- ID 36: Healthier Life (Paid) - 99 phrasers
- ID 11: Gym (Free) - 103 phrasers

### Connect with nature (3 categories)
- ID 39: Rain (Free) - 192 phrasers
- ID 25: Sunshine (Paid) - 520 phrasers
- ID 20: Ocean (Free) - 206 phrasers

### Sports (2 categories)
- ID 23: Basketball (Free) - 497 phrasers
- ID 22: Football (Free) - 513 phrasers

### Pets (2 categories)
- ID 21: Cat love (Free) - 488 phrasers
- ID 19: Dog love (Free) - 376 phrasers

### God's Blessing (1 category)
- ID 49: Biblical Verses (Free) - 152 phrasers

---

## API Response Format

```json
{
  "status": "ok",
  "count": 38,
  "categories": [
    {
      "category_id": "51",
      "category_name": "Moving On",
      "category_section": "Acquire knowledge and wisdom",
      "category_type": "Free",
      "category_image": "1693799603_kindness (6).png",
      "total_phraser": "302"
    }
    // ... more categories
  ]
}
```

---

## Notes

- Categories are fetched from the API on app initialization
- Region-specific filtering can be applied using `&region=` parameter
- Images are stored at: `http://phraser.amazingonlinecourse.com/upload/category/`
- Category data is cached locally in Floor database
