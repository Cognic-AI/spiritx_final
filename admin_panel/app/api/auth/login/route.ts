import { type NextRequest, NextResponse } from "next/server"
import { signInWithEmailAndPassword } from "firebase/auth"
import { auth } from "@/lib/firebase/config"
import { doc, getDoc } from "firebase/firestore"
import { db } from "@/lib/firebase/config"
import { sign } from "jsonwebtoken"
import { cookies } from "next/headers"

export async function POST(request: NextRequest) {
  try {
    const { email, password } = await request.json()

    // Sign in with Firebase
    const userCredential = await signInWithEmailAndPassword(auth, email, password)
    const user = userCredential.user

    // Check if user is admin
    const userDoc = await getDoc(doc(db, "users", user.uid))
    const userData = userDoc.data()

    if (!userData || userData.role !== "admin") {
      return NextResponse.json({ error: "Unauthorized. Only admins can access this panel." }, { status: 403 })
    }

    // Create JWT token
    const token = sign(
      {
        uid: user.uid,
        email: user.email,
        role: "admin",
      },
      process.env.JWT_SECRET || "default_secret",
      { expiresIn: "1d" },
    )

      // Set cookie
      ; (await
        // Set cookie
        cookies()).set({
          name: "auth_token",
          value: token,
          httpOnly: true,
          path: "/",
          secure: process.env.NODE_ENV === "production",
          maxAge: 60 * 60 * 24, // 1 day
        })

    return NextResponse.json({
      success: true,
      user: {
        uid: user.uid,
        email: user.email,
        displayName: userData.name,
      },
    })
  } catch (error: any) {
    console.error("Login error:", error)

    return NextResponse.json({ error: error.message || "Authentication failed" }, { status: 401 })
  }
}
