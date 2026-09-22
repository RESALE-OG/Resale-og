# RESALE OG — Supabase Ready

This is a prepared starter for the RESALE OG marketplace.

## What is included
- Supabase PostgreSQL schema
- Email/password auth foundation
- Profiles
- Products/listings
- Wishlist
- Cart
- Orders + order items
- Row Level Security policies
- Express API starter
- Frontend connection placeholder

## Connect it
1. Create a Supabase project.
2. In Supabase SQL Editor, paste and run `supabase_schema.sql`.
3. Copy `.env.example` to `.env`.
4. Put your Supabase Project URL and Publishable/anon key in `.env`.
5. Create `public/config.js` from `public/config.js.example` and put the same public URL/key there.
6. Run:
   npm install
   npm start
7. Open http://localhost:3000

## Important
Never put a Supabase service-role/secret key in the browser or send it to anyone.
This starter is a foundation, not a finished production marketplace. Before launch, add payment processing, image storage policies, moderation, seller verification, shipping, refunds, rate limiting, logging, legal/privacy pages, and production deployment.
