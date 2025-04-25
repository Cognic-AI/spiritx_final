import { type NextRequest, NextResponse } from "next/server"
import { db } from "@/lib/firebase/config"
import { doc, getDoc, updateDoc } from "firebase/firestore"
import { verifyToken } from "@/lib/auth"
import { auth } from "@/lib/firebase/config"
import { sendPasswordResetEmail } from "firebase/auth"
import { cookies } from "next/headers"

export async function PATCH(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    // Verify authentication
    const cookieStore = await cookies()
    const token = cookieStore.get("auth_token")?.value

    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    await verifyToken(token)

    const { status, notes } = await request.json()

    // Get reset request
    const resetDoc = await getDoc(doc(db, "password_resets", params.id))

    if (!resetDoc.exists()) {
      return NextResponse.json({ error: "Reset request not found" }, { status: 404 })
    }

    const resetData = resetDoc.data()

    // If approved, send password reset email
    if (status === "approved" && resetData.email) {
      await sendPasswordResetEmail(auth, resetData.email)
    }

    // Update reset request status
    await updateDoc(doc(db, "password_resets", params.id), {
      status,
      notes,
      updatedAt: new Date(),
    })

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Error handling password reset:", error)
    return NextResponse.json({ error: "Failed to process password reset" }, { status: 500 })
  }
}
