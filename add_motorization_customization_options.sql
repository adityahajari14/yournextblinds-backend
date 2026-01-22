-- ============================================
-- SQL Script to add Motorization Customization Options
-- For Day and Night Blinds
-- ============================================
--
-- This script adds motorization options to the database:
-- - 1 CH Remote: £150.00
-- - 2 CH Remote: £175.00
-- - 6 CH Remote: £179.00
-- - 16 CH Remote: £180.00
--
-- Also updates chain-color and cassette-bar prices:
-- - Chain Color: Grey £4.00, Black £4.00, Chrome Metal £7.00
-- - Cassette Bar: Black £18.50, Grey £18.50
--
-- ============================================

-- ============================================
-- 1. ADD MOTORIZATION OPTIONS
-- ============================================

-- Insert motorization customization options
-- Using CUID-like ID format: 'c' + 24 characters
INSERT INTO "CustomizationOption" (
    "id",
    "category",
    "optionId",
    "name",
    "description",
    "sortOrder",
    "createdAt",
    "updatedAt"
) VALUES
    -- 1 CH Remote (Base motorization price)
    (
        'c' || substr(md5('motorization-1ch-remote' || random()::text), 1, 24),
        'motorization',
        '1ch-remote',
        '1 CH Remote',
        '1 channel remote control (included with motorization)',
        0,
        NOW(),
        NOW()
    ),
    -- 2 CH Remote
    (
        'c' || substr(md5('motorization-2ch-remote' || random()::text), 1, 24),
        'motorization',
        '2ch-remote',
        '2 CH Remote',
        '2 channel remote control',
        1,
        NOW(),
        NOW()
    ),
    -- 6 CH Remote
    (
        'c' || substr(md5('motorization-6ch-remote' || random()::text), 1, 24),
        'motorization',
        '6ch-remote',
        '6 CH Remote',
        '6 channel remote control',
        2,
        NOW(),
        NOW()
    ),
    -- 16 CH Remote
    (
        'c' || substr(md5('motorization-16ch-remote' || random()::text), 1, 24),
        'motorization',
        '16ch-remote',
        '16 CH Remote',
        '16 channel remote control',
        3,
        NOW(),
        NOW()
    )
ON CONFLICT ("category", "optionId") DO UPDATE
SET
    "name" = EXCLUDED."name",
    "description" = EXCLUDED."description",
    "updatedAt" = NOW();

-- ============================================
-- 2. ADD MOTORIZATION PRICING
-- ============================================

-- Insert pricing for motorization options (fixed price, no width variation)
INSERT INTO "CustomizationPricing" (
    "id",
    "customizationOptionId",
    "widthBandId",
    "price",
    "isPerUnit",
    "createdAt",
    "updatedAt"
)
SELECT
    'c' || substr(md5(co."id" || '-pricing' || random()::text), 1, 24) as "id",
    co."id" as "customizationOptionId",
    NULL as "widthBandId", -- Fixed price for all widths
    CASE co."optionId"
        WHEN '1ch-remote' THEN 150.00
        WHEN '2ch-remote' THEN 175.00
        WHEN '6ch-remote' THEN 179.00
        WHEN '16ch-remote' THEN 180.00
    END as "price",
    false as "isPerUnit",
    NOW() as "createdAt",
    NOW() as "updatedAt"
FROM "CustomizationOption" co
WHERE co."category" = 'motorization'
    AND co."optionId" IN ('1ch-remote', '2ch-remote', '6ch-remote', '16ch-remote')
ON CONFLICT ("customizationOptionId", "widthBandId") DO UPDATE
SET
    "price" = EXCLUDED."price",
    "updatedAt" = NOW();

-- ============================================
-- 3. UPDATE CHAIN COLOR PRICES
-- ============================================

-- Update chain color prices for day/night blinds
UPDATE "CustomizationPricing" cp
SET
    "price" = CASE co."optionId"
        WHEN 'grey-plastic' THEN 4.00
        WHEN 'black-plastic' THEN 4.00
        WHEN 'chrome-metal' THEN 7.00
        ELSE cp."price"
    END,
    "updatedAt" = NOW()
FROM "CustomizationOption" co
WHERE cp."customizationOptionId" = co."id"
    AND co."category" = 'chain-color'
    AND co."optionId" IN ('grey-plastic', 'black-plastic', 'chrome-metal');

-- If grey-plastic doesn't exist, create it
INSERT INTO "CustomizationOption" (
    "id",
    "category",
    "optionId",
    "name",
    "description",
    "sortOrder",
    "createdAt",
    "updatedAt"
)
SELECT
    'c' || substr(md5('chain-color-grey-plastic' || random()::text), 1, 24),
    'chain-color',
    'grey-plastic',
    'Grey',
    'Grey plastic chain',
    1,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM "CustomizationOption"
    WHERE "category" = 'chain-color' AND "optionId" = 'grey-plastic'
)
ON CONFLICT ("category", "optionId") DO UPDATE
SET
    "name" = EXCLUDED."name",
    "updatedAt" = NOW();

-- Add pricing for grey-plastic if it doesn't exist
INSERT INTO "CustomizationPricing" (
    "id",
    "customizationOptionId",
    "widthBandId",
    "price",
    "isPerUnit",
    "createdAt",
    "updatedAt"
)
SELECT
    'c' || substr(md5(co."id" || '-pricing' || random()::text), 1, 24),
    co."id",
    NULL,
    4.00,
    false,
    NOW(),
    NOW()
FROM "CustomizationOption" co
WHERE co."category" = 'chain-color' AND co."optionId" = 'grey-plastic'
    AND NOT EXISTS (
        SELECT 1 FROM "CustomizationPricing"
        WHERE "customizationOptionId" = co."id" AND "widthBandId" IS NULL
    )
ON CONFLICT ("customizationOptionId", "widthBandId") DO UPDATE
SET
    "price" = 4.00,
    "updatedAt" = NOW();

-- ============================================
-- 4. UPDATE CASSETTE BAR PRICES
-- ============================================

-- Update cassette matching bar prices
UPDATE "CustomizationPricing" cp
SET
    "price" = CASE co."optionId"
        WHEN 'black' THEN 18.50
        WHEN 'grey' THEN 18.50
        ELSE cp."price"
    END,
    "updatedAt" = NOW()
FROM "CustomizationOption" co
WHERE cp."customizationOptionId" = co."id"
    AND co."category" = 'cassette-bar'
    AND co."optionId" IN ('black', 'grey');

-- Update names for cassette-bar options
UPDATE "CustomizationOption"
SET
    "name" = CASE "optionId"
        WHEN 'white' THEN 'White Standard'
        ELSE "name"
    END,
    "updatedAt" = NOW()
WHERE "category" = 'cassette-bar';

-- ============================================
-- 5. VERIFICATION QUERIES
-- ============================================

-- Verify motorization options were added
SELECT 
    co."category",
    co."optionId",
    co."name",
    cp."price"
FROM "CustomizationOption" co
LEFT JOIN "CustomizationPricing" cp ON cp."customizationOptionId" = co."id"
WHERE co."category" = 'motorization'
ORDER BY co."sortOrder";

-- Verify chain color prices were updated
SELECT 
    co."category",
    co."optionId",
    co."name",
    cp."price"
FROM "CustomizationOption" co
LEFT JOIN "CustomizationPricing" cp ON cp."customizationOptionId" = co."id" AND cp."widthBandId" IS NULL
WHERE co."category" = 'chain-color'
ORDER BY co."sortOrder";

-- Verify cassette bar prices were updated
SELECT 
    co."category",
    co."optionId",
    co."name",
    cp."price"
FROM "CustomizationOption" co
LEFT JOIN "CustomizationPricing" cp ON cp."customizationOptionId" = co."id" AND cp."widthBandId" IS NULL
WHERE co."category" = 'cassette-bar'
ORDER BY co."sortOrder";
