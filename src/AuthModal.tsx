import { FormEvent, useEffect, useState } from 'react'
import {
  GoogleAuthProvider, createUserWithEmailAndPassword, sendEmailVerification,
  sendPasswordResetEmail, signInWithEmailAndPassword, signInWithPopup, updateProfile,
} from 'firebase/auth'
import { auth, firebaseConfigured } from './firebase'

export type AuthMode = 'login' | 'signup'

const ERRORS: Record<string, string> = {
  'auth/invalid-email': 'Enter a valid email address.',
  'auth/missing-password': 'Enter your password.',
  'auth/invalid-credential': 'Email or password is incorrect.',
  'auth/user-not-found': 'No account found with this email.',
  'auth/wrong-password': 'Email or password is incorrect.',
  'auth/email-already-in-use': 'An account with this email already exists. Log in instead.',
  'auth/weak-password': 'Password must be at least 6 characters.',
  'auth/too-many-requests': 'Too many attempts. Try again in a few minutes.',
  'auth/network-request-failed': 'Network error. Check your connection.',
  'auth/popup-closed-by-user': 'Google sign-in was cancelled.',
  'auth/unauthorized-domain': `This domain (${window.location.hostname}) is not authorized in Firebase. Add it under Authentication → Settings → Authorized domains.`,
  'auth/popup-blocked': 'Your browser blocked the Google popup. Allow popups for this site and try again.',
  'auth/cancelled-popup-request': 'Google sign-in was cancelled.',
  'auth/configuration-not-found': 'Firebase Authentication is not set up yet. In Firebase Console open Authentication → Get started, then enable the Email/Password (and Google) sign-in methods.',
  'auth/invalid-api-key': 'The Firebase API key is invalid. Check your VITE_FIREBASE_API_KEY.',
  'auth/api-key-not-valid.-please-pass-a-valid-api-key.': 'The Firebase API key is invalid. Check your VITE_FIREBASE_API_KEY.',
  'auth/operation-not-allowed': 'This sign-in method is not enabled in Firebase yet.',
}
const errText = (e: unknown) => {
  const code = (e as { code?: string }).code ?? ''
  return ERRORS[code] ?? `Something went wrong (${code || 'unknown error'}). Please try again.`
}

export default function AuthModal({ mode, onMode, onClose }: { mode: AuthMode; onMode: (m: AuthMode) => void; onClose: () => void }) {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [info, setInfo] = useState('')
  const signup = mode === 'signup'

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose()
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onClose])
  useEffect(() => { setError(''); setInfo('') }, [mode])

  const run = async (fn: () => Promise<void>) => {
    if (!auth) return
    setBusy(true); setError(''); setInfo('')
    try { await fn() } catch (e) { setError(errText(e)) } finally { setBusy(false) }
  }

  const submit = (e: FormEvent) => {
    e.preventDefault()
    if (signup) {
      if (!name.trim()) return setError('Enter your full name.')
      if (password !== confirm) return setError('Passwords do not match.')
    }
    run(async () => {
      if (signup) {
        const cred = await createUserWithEmailAndPassword(auth!, email.trim(), password)
        await updateProfile(cred.user, { displayName: name.trim() })
        await sendEmailVerification(cred.user)
      } else {
        await signInWithEmailAndPassword(auth!, email.trim(), password)
      }
      onClose()
    })
  }

  const google = () => run(async () => { await signInWithPopup(auth!, new GoogleAuthProvider()); onClose() })
  const reset = () => {
    if (!email.trim()) return setError('Enter your email first, then press Forgot password.')
    run(async () => { await sendPasswordResetEmail(auth!, email.trim()); setInfo('Password reset link sent. Check your inbox.') })
  }

  return (
    <div className="overlay" onMouseDown={(e) => e.target === e.currentTarget && onClose()}>
      <div className="modal" role="dialog" aria-modal="true" aria-labelledby="auth-title">
        <button className="mclose" aria-label="Close" onClick={onClose}>✕</button>
        <div className="mhead">
          <img src="/logo.png" alt="" />
          <h2 id="auth-title">{signup ? 'Create your account' : 'Welcome back'}</h2>
          <p>{signup ? 'Sign up to apply for admission and access your portal.' : 'Log in to your Indus Virtual School account.'}</p>
        </div>
        <div className="tabs" role="tablist">
          <button role="tab" aria-selected={!signup} className={!signup ? 'on' : ''} onClick={() => onMode('login')}>Log in</button>
          <button role="tab" aria-selected={signup} className={signup ? 'on' : ''} onClick={() => onMode('signup')}>Sign up</button>
        </div>

        {!firebaseConfigured && <div className="note warn">Firebase is not configured yet. Add the <code>VITE_FIREBASE_*</code> variables (see README), then restart.</div>}

        <form onSubmit={submit} noValidate>
          {signup && (
            <label>Full name
              <input value={name} onChange={(e) => setName(e.target.value)} autoComplete="name" placeholder="e.g. Ayesha Khan" />
            </label>
          )}
          <label>Email
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} autoComplete="email" placeholder="you@example.com" />
          </label>
          <label>Password
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} autoComplete={signup ? 'new-password' : 'current-password'} placeholder="At least 6 characters" />
          </label>
          {signup && (
            <label>Confirm password
              <input type="password" value={confirm} onChange={(e) => setConfirm(e.target.value)} autoComplete="new-password" placeholder="Repeat password" />
            </label>
          )}
          {!signup && <button type="button" className="link" onClick={reset}>Forgot password?</button>}
          {error && <div className="note err" role="alert">{error}</div>}
          {info && <div className="note ok">{info}</div>}
          <button className="btn primary full" type="submit" disabled={busy || !firebaseConfigured}>
            {busy ? 'Please wait…' : signup ? 'Create account' : 'Log in'}
          </button>
        </form>

        <div className="or"><span>or</span></div>
        <button className="btn outline full" type="button" onClick={google} disabled={busy || !firebaseConfigured}>Continue with Google</button>
        <p className="switch">
          {signup ? 'Already have an account?' : 'New to Indus Virtual School?'}{' '}
          <button className="link" onClick={() => onMode(signup ? 'login' : 'signup')}>{signup ? 'Log in' : 'Sign up'}</button>
        </p>
      </div>
    </div>
  )
}
