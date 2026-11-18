import { useEffect, useState } from 'react'

const NAV = ['Home', 'Admissions', 'Careers', 'About', 'Blogs', 'Contact']
const PORTALS = ['Admin Login', 'Teacher Login', 'Student Login', 'Parent Login']
const LEGAL = ['Privacy Policy', 'Terms of Service', 'Account Deletion']

const STATS = [
  { v: '66+', l: 'PCTB BOOKS' },
  { v: 'KG-8', l: 'ALL CLASSES' },
  { v: 'SECP', l: 'REG. (PVT) LTD' },
  { v: '4', l: 'PORTALS' },
  { v: '100%', l: 'ONLINE' },
]

interface Feature { icon: string; title: string; text: string; tint: string; tag: string }
const FEATURES: Feature[] = [
  { icon: '📊', title: 'LMS Dashboard', text: 'One place for classes, homework, results and announcements.', tint: '#fde68a', tag: 'KG to 8th Grade' },
  { icon: '🎥', title: 'Live Classes', text: 'Join real-time video classes with certified teachers. Interactive learning with whiteboard and chat.', tint: '#e5e7eb', tag: 'KG to 8th Grade' },
  { icon: '📹', title: 'Recorded Lectures', text: 'Missed a class? Watch recorded lectures anytime at your own pace.', tint: '#fbcfe8', tag: 'KG to 8th Grade' },
  { icon: '📝', title: 'Online Exams', text: 'MCQ and subjective exams with timer, auto-grading, and instant results.', tint: '#fde68a', tag: 'KG to 8th Grade' },
  { icon: '🏅', title: 'Results & Report Cards', text: 'Subject-wise marks, grades, percentages, and official report cards.', tint: '#a7f3d0', tag: 'KG to 8th Grade' },
  { icon: '📚', title: 'Homework & Classwork', text: 'View, submit online, and get teacher feedback.', tint: '#bae6fd', tag: 'KG to 8th Grade' },
  { icon: '🗓️', title: 'Attendance Tracking', text: 'Daily attendance with instant parent visibility.', tint: '#fde68a', tag: 'KG to 8th Grade' },
  { icon: '📖', title: 'Study Material', text: 'PCTB textbooks and notes available digitally.', tint: '#fed7aa', tag: 'KG to 8th Grade' },
  { icon: '👨‍👩‍👧', title: 'Parent Portal', text: 'Follow your child’s progress, fees and attendance.', tint: '#ddd6fe', tag: 'KG to 8th Grade' },
  { icon: '🧑‍🏫', title: 'Teacher Portal', text: 'Plan lessons, mark work and manage classes.', tint: '#fbcfe8', tag: 'KG to 8th Grade' },
  { icon: '💳', title: 'Fee Management', text: 'Simple fee vouchers and payment tracking.', tint: '#a7f3d0', tag: 'KG to 8th Grade' },
  { icon: '⏰', title: 'Timetable', text: 'Daily class schedule with reminders.', tint: '#bae6fd', tag: 'KG to 8th Grade' },
]
const ACCENTS = ['#f59e0b', '#fbbf24', '#f59e0b', '#fbbf24', '#10b981', '#38bdf8']
const INTERVAL = 4000

function Carousel() {
  const n = FEATURES.length
  const [active, setActive] = useState(3)

  useEffect(() => {
    const t = setTimeout(() => setActive((a) => (a + 1) % n), INTERVAL)
    return () => clearTimeout(t)
  }, [active, n])

  return (
    <div className="carousel">
      <div className="stage">
        {FEATURES.map((f, i) => {
          let o = i - active
          if (o > n / 2) o -= n
          if (o < -n / 2) o += n
          const abs = Math.abs(o)
          const isActive = o === 0
          const style = {
            transform: `translateX(calc(-50% + ${o * 315}px)) translateY(${abs * 24}px) rotate(${o * 1.6}deg) scale(${1 - abs * 0.1})`,
            opacity: abs > 2 ? 0 : 1 - abs * 0.42,
            zIndex: 10 - abs,
            pointerEvents: abs > 2 ? 'none' : 'auto',
            borderTopColor: ACCENTS[i % ACCENTS.length],
          } as React.CSSProperties
          return (
            <article key={f.title} className={'fcard' + (isActive ? ' on' : '')} style={style} onClick={() => setActive(i)}>
              <span className="fnum">#{String(i + 1).padStart(2, '0')}</span>
              <div className="ficon" style={{ background: f.tint }}>{f.icon}</div>
              <h3>{f.title}</h3>
              <p>{f.text}</p>
              <div className="ffoot">
                <span className="pill">PCTB 2026</span>
                <span className="grade">{f.tag}</span>
              </div>
              {isActive && <i key={active} className="bar" style={{ animationDuration: `${INTERVAL}ms` }} />}
            </article>
          )
        })}
      </div>
      <div className="dots">
        {FEATURES.map((f, i) => (
          <button key={f.title} aria-label={f.title} className={i === active ? 'dot on' : 'dot'} onClick={() => setActive(i)} />
        ))}
      </div>
    </div>
  )
}

export default function App() {
  const [dark, setDark] = useState(false)
  useEffect(() => { document.documentElement.dataset.theme = dark ? 'dark' : 'light' }, [dark])

  return (
    <>
      <header className="nav">
        <div className="wrap navin">
          <a className="brand" href="/">
            <img src="/logo.png" alt="Indus Virtual School" />
            <span><b>Indus Virtual School</b><small>Quality Online Schooling</small></span>
          </a>
          <nav className="links">
            {NAV.map((l, i) => <a key={l} href="#" className={i === 0 ? 'cur' : ''}>{l}</a>)}
          </nav>
          <div className="acts">
            <button className="circ" aria-label="Toggle theme" onClick={() => setDark(!dark)}>{dark ? '☀' : '☾'}</button>
            <button className="ghost">文A&nbsp; Urdu</button>
            <button className="ghost">Sign In</button>
          </div>
        </div>
      </header>

      <main>
        <section className="hero">
          <div className="wrap herogrid">
            <div className="copy">
              <span className="chip amber"><i className="d" />ADMISSIONS OPEN — SESSION 2026</span><br />
              <span className="chip green">🏛 <b>SECP Registered</b> <em>•</em> <code>CUIN: 0366188</code> ✓</span>
              <h1>PAKISTAN'S<br />PREMIER<br /><span>ONLINE SCHOOL</span></h1>
              <p>Complete KG to 8th grade education following Punjab Board (PCTB 2026). Officially incorporated as <b>Indus Virtual School (Private) Limited</b> under SECP.</p>
              <div className="btns">
                <a className="btn primary" href="#">Apply for Admission →</a>
                <a className="btn outline" href="#features">Explore Features ↓</a>
              </div>
            </div>
            <div className="art">
              <img src="/hero.webp" alt="Student learning on the Indus Virtual School portal" />
              <div className="float">
                <span>🎓</span>
                <div><b>PCTB 2026 Curriculum</b><small>KG to 8th Class • Live & Interactive</small></div>
              </div>
            </div>
          </div>
        </section>

        <section className="stats" aria-label="Key facts">
          <div className="marquee">
            <div className="track">
              {[...STATS, ...STATS].map((s, i) => (
                <div className="stat" key={i} aria-hidden={i >= STATS.length}>
                  <img src={`/stat${(i % STATS.length) + 1}.png`} alt="" />
                  <div><b>{s.v}</b><small>{s.l}</small></div>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="features" id="features">
          <div className="wrap"><h2>Platform Features</h2></div>
          <Carousel />
        </section>
      </main>

      <footer className="foot">
        <div className="wrap fgrid">
          <div>
            <div className="brand">
              <img src="/logo.png" alt="" />
              <span><b>Indus Virtual School</b><small>Quality Online Schooling</small></span>
            </div>
            <p className="fdesc">Complete online school platform for KG to 8th grade following Punjab Board (PCTB 2026) curriculum.</p>
            <div className="secp">✓ <span><b>SECP Registered:</b> Indus Virtual School (Pvt) Ltd <em>•</em> <code>CUIN: 0366188</code></span></div>
            <p className="addr">📍 Office 503, Gulberg empire, Civic Center, Executive Block Koral Town, Islamabad, 44000</p>
            <p className="addr">⏰ Monday to Saturday: 9:00 AM - 5:00 PM</p>
          </div>
          <div>
            <h4>Quick Links</h4>
            {NAV.map((l, i) => <a key={l} href="#" className={i === 0 ? 'fl cur' : 'fl'}>{i === 0 && <i className="d" />}{l}</a>)}
          </div>
          <div>
            <h4>Portals</h4>
            {PORTALS.map((l) => <a key={l} href="#" className="fl">{l}</a>)}
          </div>
          <div>
            <h4>Legal</h4>
            {LEGAL.map((l) => <a key={l} href="#" className="fl">{l}</a>)}
          </div>
        </div>
        <div className="wrap copy-r">
          <span>© 2026 Indus Virtual School (Private) Limited. All rights reserved.</span>
          <code>v1.0.1</code>
        </div>
      </footer>
    </>
  )
}
