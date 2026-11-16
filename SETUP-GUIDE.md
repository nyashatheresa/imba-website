# IMBA secure website content management — setup

This package contains the complete public website and a real admin interface. It is **not connected or deployed yet**. To activate publishing, create a Supabase project and deploy the site to an HTTPS host. No Supabase account, credentials or hosting access were supplied, so those steps cannot be performed automatically.

## 1. Create the backend
1. Create a Supabase project at https://supabase.com/dashboard .
2. Open **SQL Editor**, paste the complete `setup-supabase.sql`, and run it **once** on a new project. The script creates content, access policies and a public image bucket.
3. Open **Authentication → Users** and add the owner/admin email as a user, with a secure password. Use Supabase's admin controls to create/invite the user; don't build public admin registration.
4. Copy the new user's **UUID**. In SQL Editor, run:
   `insert into public.site_admins(user_id) values ('YOUR-ADMIN-USER-UUID');`
5. Open **Project Settings → API** (or **Connect**) and copy the project URL and **publishable/anon** key into `supabase-config.js`. These are safe to put in browser code **only with RLS enabled**. Never put the service-role or secret key in frontend files.

## 2. Test locally
- In VS Code open this folder and use **Live Server** to serve `index.html` (not `file://`).
- Open `admin.html`, sign in with the admin email/password, upload a photo and click **Publish changes**.
- Refresh the public homepage to confirm it displays the new photo.
- Verify that signing in with a different account does **not** grant edit access.

## 3. Publish
- Deploy all website files to an HTTPS static host such as Netlify, Cloudflare Pages or Vercel. This can be done by uploading the folder or connecting a Git repository.
- Set the production domain in Supabase **Authentication → URL Configuration**. Ensure sign-in is restricted to known admins; turn off public signups if not needed.
- Use `https://your-domain/admin.html` for the admin dashboard. The page URL is not secret; authorization is enforced by database/storage policies.
- Make sure you control rights to any images you upload. Placeholder inspiration photographs are not evidence of IMBA's completed work.

## What staff can edit
- Five homepage slideshow images, and four animated banner images each for About, Services, Signature Styles and Contact.
- Four service-price captions and the homepage statement.
- Staff can upload JPG/PNG/WebP images up to 10 MB to the managed bucket or paste a direct HTTPS image URL.

## Notes and limits
- Only the Supabase-authenticated admin UUIDs entered into `site_admins` can publish or upload. The public website can read content but cannot modify it.
- Photos are public assets and should not include confidential customer information.
- Public website content falls back to built-in text and photos if the backend is unavailable.
- Image uploads are stored permanently until explicitly deleted from Supabase Storage; replacing an image does not automatically delete its old file.
- Content publishing updates the site for everyone after a refresh. Browser caching may briefly delay visibility.
- The contact enquiry opens WhatsApp; it does not store customer enquiries in the database.
- There is no automatic quote calculator or invoicing system. “Quotes” here means editable price captions and homepage statement, not generated customer quotations.
- Supabase pricing, account creation, domain ownership and hosting are external requirements.


## Full dashboard

The new `admin.html` now displays separate editing tabs for Homepage, About, Services, Projects, Contact and Contacts & Branding. It automatically exposes the text and photographs found in the public pages, and allows uploading images to the `imba-images` Supabase Storage bucket.

**Important:** The editor is only usable after configuring `supabase-config.js`, running `setup-supabase.sql`, creating a user in Supabase Authentication and adding that user's UUID to `site_admins`. The dashboard will not work offline or by simply double-clicking the HTML file. Deploy on Vercel or use a local HTTP server.

After setup, sign in at `/admin.html`, edit content and click **Save & publish changes**. Changes appear to visitors after refreshing. Do not share admin credentials.
