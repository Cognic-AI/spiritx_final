import { type NextRequest, NextResponse } from "next/server"
import { db } from "@/lib/firebase/config"
import { doc, getDoc, updateDoc } from "firebase/firestore"
import { verifyToken } from "@/lib/auth"

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    // Verify authentication
    // const token = request.cookies.get("auth_token")?.value
    // if (!token) {
    //   return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    // }

    // await verifyToken(token)

    // Get verification document
    const verificationDoc = await getDoc(doc(db, "verifications", params.id))

    if (!verificationDoc.exists()) {
      return NextResponse.json({ error: "Verification not found" }, { status: 404 })
    }

    return NextResponse.json(verificationDoc.data())
  } catch (error) {
    console.error("Error fetching verification:", error)
    return NextResponse.json({ error: "Failed to fetch verification" }, { status: 500 })
  }
}

export async function PATCH(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    // Verify authentication
    // const token = request.cookies.get("auth_token")?.value
    // if (!token) {
    //   return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    // }

    // await verifyToken(token)

    const { status, notes } = await request.json()

    // Update verification status
    await updateDoc(doc(db, "verifications", params.id), {
      status,
      notes,
      updatedAt: new Date(),
    })

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Error updating verification:", error)
    return NextResponse.json({ error: "Failed to update verification" }, { status: 500 })
  }
}
