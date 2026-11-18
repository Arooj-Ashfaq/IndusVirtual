# Indus Virtual School — Homepage

React + TypeScript (Vite) homepage.

## Run locally
```bash
npm install
npm run dev
```

## Deploy on Vercel
1. Import this repo at https://vercel.com/new
2. Framework preset: **Vite** (auto-detected, settings come from `vercel.json`)
3. Click **Deploy**

Build command: `npm run build` · Output directory: `dist`

## Firebase Auth setup
1. Firebase Console → create a project → **Add app → Web** and copy the config.
2. **Build → Authentication → Sign-in method**: enable **Email/Password** and **Google**.
3. **Authentication → Settings → Authorized domains**: add your Vercel domain (e.g. `your-app.vercel.app`) and any custom domain.
4. Locally: copy `.env.example` to `.env` and fill in the values.
5. Vercel: Project → Settings → Environment Variables → add the same six `VITE_FIREBASE_*` keys, then redeploy.
