# IngredientConservo

https://nathaferrari.github.io/IngredientConservo-Deploy

Your pantry, your legacy. A Flutter app to track groceries, reduce food waste, and generate recipes from what you already have.



--------------------------------------------------------

Database Collections (LeftoverLegends)
1. rewards
Stores discount/reward coupons that users have redeemed.

ownerId (text, required) — Links to the user who owns the reward.

couponCode (varchar, required) — The unique coupon/discount code.

storeName (varchar, required) — Name of the store where the coupon applies (e.g., Too Good To Go, Migros, Alnatura).

discount (varchar, required) — The discount value/amount.

pointsCost (integer, required) — How many loyalty points were spent to redeem it.

redeemedAt (datetime, required) — Timestamp when the reward was redeemed.

expiresAt (datetime, required) — Expiration date of the coupon.

$id, $createdAt, $updatedAt — Auto-generated Appwrite metadata.

2. user_profile
Stores user-specific data for the gamification/loyalty system.

ownerId (text, required) — Unique Appwrite user ID.

country (varchar, required) — User's country.

points (integer, default: 0) — Current loyalty points balance.

totalSpent (double, default: 0) — Total money saved/spent tracking.

totalWasted (double, default: 0) — Amount of food waste avoided (tracked).

$id, $createdAt, $updatedAt — Auto-generated Appwrite metadata.

3. item
Stores food/grocery items that users track in their inventory.

name (text, required) — Name of the item.

emoji (text, required) — Emoji icon representing the item.

expirationDate (datetime, required) — When the item expires.

category (text, required) — Category of the item (e.g., dairy, produce).

ownerId (varchar, required) — Links to the user who owns the item.

price (double) — Price of the item.

unit (varchar, required) — Currency or unit (e.g., CHF).

quantity (double, default: 0) — Quantity of the item.

measure (text, default: "u") — Measurement unit (e.g., "u" for units).

$id, $createdAt, $updatedAt — Auto-generated Appwrite metadata.

Database totals:

Functions
1. ReceiptHandler
Purpose: Processes receipts (scans/parses receipt images) and automatically creates item entries from them. Uses Groq AI APIs.

Runtime: Node.js 25, Entrypoint: src/main.js

Git repo: receipt-handler (main branch), auto-deploys from GitHub.

Env vars: GROQ_API_KEY, HF_TOKEN

Schedule: Runs every minute (* * * * * cron).

Timeout: 15s

Access: Any user

Resources: 0.5 CPU, 512 MB RAM

2. recipe_generator
Purpose: Generates recipe suggestions based on available ingredients. Uses Hugging Face AI APIs.

Runtime: Node.js 25, Entrypoint: src/main.js

Git repo: recipes-creator (main branch), auto-deploys from GitHub.

Env vars: OCR_API_KEY, HF_TOKEN

Schedule: None (triggered on-demand).

Timeout: 15s

Access: Any user

Resources: 0.5 CPU, 512 MB RAM
