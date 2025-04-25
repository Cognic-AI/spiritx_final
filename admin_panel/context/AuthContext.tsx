"use client"

import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import { useRouter, usePathname } from "next/navigation"
import { onAuthStateChanged, signOut } from "firebase/auth"
import { doc, getDoc } from "firebase/firestore"
import { auth, db } from "@/lib/firebase/config"

interface User {
  uid: string
  email: string | null
  displayName: string | null
  isAdmin: boolean
}

interface AuthContextType {
  user: User | null
  isLoading: boolean
  logout: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const router = useRouter()
  const pathname = usePathname()

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        try {
          // Check if user is admin
          const userDoc = await getDoc(doc(db, "users", firebaseUser.uid))
          const userData = userDoc.data()

          if (userData && userData.role === "admin") {
            setUser({
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              displayName: userData.name || firebaseUser.displayName,
              isAdmin: true,
            })
          } else {
            // Not an admin, sign out
            await signOut(auth)
            setUser(null)
            if (pathname !== "/") {
              router.push("/")
            }
          }
        } catch (error) {
          console.error("Error checking user role:", error)
          setUser(null)
        }
      } else {
        setUser(null)
        if (pathname !== "/" && pathname !== undefined) {
          router.push("/")
        }
      }
      setIsLoading(false)
    })

    return () => unsubscribe()
  }, [router, pathname])

  async function logout() {
    setIsLoading(true)
    try {
      await signOut(auth)
      router.push("/")
    } catch (error) {
      console.error("Logout error:", error)
    } finally {
      setIsLoading(false)
    }
  }

  return <AuthContext.Provider value={{ user, isLoading, logout }}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)

  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider")
  }

  return context
}
