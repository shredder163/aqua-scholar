# AQUA Scholar — private single-user Supabase PWA

**Status:** Source code only. NOT deployed; Gmail and Drive background sync NOT implemented or authorized.

## What's working
- Google sign-in via Supabase Auth, gated to verified `asaga@hawaii.edu`.
- Additional database RLS hardening for **all five existing academic tables**.
- Persistent semesters, courses, assignments, statuses and manually entered grades.
- Pending import suggestions view; responsive, installable PWA shell.

## 1. Run private-user SQL migration
Run `supabase/migrations/202610270002_private_account.sql` in the Supabase SQL Editor **after** your initial migration. This replaces existing permissive per-user policies with an owner-email check. Review SQL before executing. It does not erase data.

## 2. Configure Google authentication
In Google Cloud, create an OAuth web client and add the authorized redirect URI:
`https://fxbjmjwgowbclmcqccqw.supabase.co/auth/v1/callback`

In Supabase > Authentication > Providers > Google, enable the provider and enter your client ID and secret **in the dashboard only**. Keep OAuth app in Testing with your UH address as a test user, subject to Workspace policy. In Supabase > Authentication > URL Configuration, set Site URL to the eventual deployed HTTPS frontend URL, and add that URL to the redirect allow list. Set your OAuth consent screen and Google APIs according to actual requested scopes. **Do not request Gmail/Drive scopes in this initial sign-in**. Your school administrator may block third-party apps.

## 3. Configure frontend
Copy `.env.example` to `.env.local`, add the **publishable** Supabase key (never the secret/service-role key). Then:
```
npm install
npm run dev
```
For production: `npm run build` generates `dist/`. Deploy to Vercel, Netlify, or Cloudflare Pages as a Vite static app. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` in the hosting dashboard. Use HTTPS.

## 4. iPhone install
In Safari, open the deployed HTTPS site, tap Share > Add to Home Screen. PWA shell includes a manifest and SVG icon. Offline functionality is not implemented.

## 5. Gmail/Drive integration still required
Use a separate backend-only OAuth flow with least-privilege `gmail.readonly` and `drive.readonly` (or narrower scopes where workable), encrypted refresh tokens, server-side scheduled Edge Functions, deduplication, per-file provenance, and a review queue. The folder to scan is `1JjgldoDX4jAMYhklCN0vuFAqolIKozwi`. This package **does not** read Gmail or Drive and **does not** schedule sync. Never place Google refresh tokens in browser-accessible tables. Production readiness requires testing RLS with a second account, verifying provider access controls, reviewing Google OAuth consent, and auditing the app.

## Important
Only the owner can access academic tables, but Supabase Auth itself may still allow other people to create accounts unless additional provider/signup restrictions are configured. The RLS migration protects data even if another user signs in. If email ownership changes or you want to transfer the app, review the owner function and update it deliberately.
