# Shopify Product Extractor

A script to extract complete product information from any Shopify store product URL.

## Features

- ✅ Extracts product title, description, and pricing
- ✅ Fetches all product images with alt text
- ✅ Extracts product variants (if available)
- ✅ Gets categories and tags
- ✅ Extracts SEO metadata (meta title, description, canonical URL)
- ✅ Parses JSON-LD structured data
- ✅ Handles multiple data sources (JSON-LD, meta tags, HTML elements)
- ✅ Outputs structured JSON data

## Installation

Dependencies are already installed:
- `axios` - For HTTP requests
- `cheerio` - For HTML parsing

## Usage

### Basic Usage

Extract product data and display in console:

```bash
npm run extract:shopify <product-url>
```

Example:
```bash
npm run extract:shopify https://1clickblinds.co.uk/products/plain-soft-white-motorised-day-and-night-blind
```

### Save to File

Extract product data and save to a JSON file:

```bash
npm run extract:shopify <product-url> <output-file>
```

Example:
```bash
npm run extract:shopify https://1clickblinds.co.uk/products/plain-soft-white-motorised-day-and-night-blind product.json
```

### Programmatic Usage

You can also import and use the function in your code:

```typescript
import { extractShopifyProduct } from './extractShopifyProduct';

const product = await extractShopifyProduct('https://example.com/products/product-name');
console.log(product);
```

## Output Format

The script outputs a JSON object with the following structure:

```json
{
  "title": "Product Name",
  "description": "Product description...",
  "slug": "product-name",
  "canonicalUrl": "https://example.com/products/product-name",
  "price": 17.71,
  "originalPrice": 32.00,
  "currency": "GBP",
  "images": [
    {
      "url": "https://example.com/image.jpg",
      "alt": "Product image",
      "position": 0
    }
  ],
  "variants": [
    {
      "id": "123",
      "title": "Default",
      "price": 17.71,
      "available": true
    }
  ],
  "categories": ["Category 1", "Category 2"],
  "tags": ["tag1", "tag2"],
  "metaTitle": "Product Name | Store",
  "metaDescription": "Product description for SEO",
  "vendor": "Brand Name",
  "productType": "Type",
  "stockStatus": "IN_STOCK",
  "availability": "https://schema.org/InStock"
}
```

## Data Extraction Methods

The script uses multiple methods to extract data (in order of reliability):

1. **JSON-LD Structured Data** - Most reliable, follows schema.org standards
2. **Meta Tags** - Open Graph and Twitter Card metadata
3. **HTML Elements** - Product-specific selectors
4. **Shopify Window Object** - Shopify-specific JavaScript variables (if available)

## Notes

- The script respects robots.txt and uses a standard browser User-Agent
- Some stores may have rate limiting or bot protection
- Image URLs are automatically converted to absolute URLs
- The script handles both relative and absolute URLs
- Duplicate images are automatically filtered out

## Error Handling

If extraction fails, the script will:
- Display a clear error message
- Exit with code 1
- Preserve any partial data that was successfully extracted

## Examples

### Extract and save to file
```bash
npm run extract:shopify https://1clickblinds.co.uk/products/plain-soft-white-motorised-day-and-night-blind output.json
```

### Extract multiple products (bash loop)
```bash
for url in \
  "https://example.com/products/product1" \
  "https://example.com/products/product2"; do
  npm run extract:shopify "$url" "products/$(basename $url).json"
done
```

## Integration with Database

The extracted JSON can be used with the existing import scripts or converted to SQL using the schema in `Yournextblinds/prisma/schema.prisma`.

Example SQL generation (pseudo-code):
```typescript
const product = await extractShopifyProduct(url);
// Convert to SQL INSERT statements
// Use the generated SQL script pattern from add_plain_soft_white_motorised_day_night_blind.sql
```
