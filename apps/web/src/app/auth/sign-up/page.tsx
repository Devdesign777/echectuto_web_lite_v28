import Link from 'next/link'
import { signUp } from '../actions'

export default function SignUpPage() {
  return <main><h1>Créer un compte</h1><form action={signUp}><label>Pseudonyme<input name="username" minLength={3} maxLength={32} required /></label><label>E-mail<input name="email" type="email" autoComplete="email" required /></label><label>Mot de passe<input name="password" type="password" autoComplete="new-password" minLength={8} required /></label><button type="submit">S'inscrire</button></form><p><Link href="/auth/login">Déjà inscrit ? Se connecter</Link></p></main>
}
